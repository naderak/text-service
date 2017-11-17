# frozen_string_literal: true
class CatalogController < ApplicationController

  include Blacklight::Catalog

  configure_blacklight do |config|
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
        :qt => 'search',
        :rows => 10,
        :fq => ['application_ssim:ADL'],
        :hl => 'true',
        :'hl.snippets' => '3',
        :'hl.simple.pre' => '<em class="highlight" >',
        :'hl.simple.post' => '</em>'
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'
    #config.document_solr_path = 'get'

    config.index.title_field = 'work_title_tesim'
    config.index.display_type_field = 'cat_ssi'

    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field 'author_name_ssim', :label => 'Forfatter', :single => true, :limit => 10, :collapse => false
    config.add_facet_field 'perioid_ssi', :label => 'Periode', :single => true, :limit => 10, :collapse => false, helper_method: :get_period_name

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    config.add_index_field 'author_id_ssi', :label => 'Forfatter', helper_method: :author_link, short_form: true, itemprop: :author
    # if we have no author_id_ssi (link to author portrait, just show the author name)
    config.add_index_field 'author_name_tesim', :label => 'Forfatter',  short_form: true, itemprop: :author, unless: proc {|_context, _field_config, doc| doc['author_id_ssi'].present?}
    config.add_index_field 'volume_title_tesim', :label => 'Anvendt udgave', helper_method: :show_volume, short_form: true, itemprop: :isPartOf, unless: proc { |_context, _field_config, doc | doc.id == doc['volume_id_ssi'] }
    config.add_index_field 'editor_ssi', :label => 'Redaktør', itemprop: :editor

    # Work show fields
    config.add_show_field 'author_id_ssi', :label => 'Forfatter', helper_method: :author_link, itemprop: :author
    config.add_show_field 'volume_title_tesim', :label => 'Anvendt udgave', helper_method: :show_volume, itemprop: :isPartOf, unless: proc { |_context, _field_config, doc | doc.id == doc['volume_id_ssi'] }
    #config.add_show_field 'publisher_tesim', :label => 'Udgiver', unless: proc { |_context, _field_config, doc | doc['cat_ssi'] == 'volume' }
    #config.add_show_field 'place_published_tesim', :label => 'Udgivelsessted'
    #config.add_show_field 'date_published_ssi', :label => 'Udgivelsesdato'


    config.show.document_actions.citation.if = :render_citation_action?

    end


    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
 # end

  def is_text_search?
    ['authors','periods',"allworks"].exclude? action_name
  end

  def has_search_parameters?
    super || !is_text_search?
  end

  def render_email_action?
    current_user.present? && self.class == CatalogController
  end

  def render_feedback_action?
    current_user.present? && self.class == CatalogController
  end

  def render_sms_action?
    false
  end

  def render_citation_action?
    self.class == CatalogController
  end
end
