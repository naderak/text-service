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

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    config.index.title_field = 'work_title_tesim'
    config.index.display_type_field = 'cat_ssi'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'
    #config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
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

    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

 #N   config.add_facet_field 'format', label: 'Format'
 #N   config.add_facet_field 'pub_date', label: 'Publication Year', single: true
 #N   config.add_facet_field 'subject_topic_facet', label: 'Topic', limit: 20, index_range: 'A'..'Z' #N   config.add_facet_field 'language_facet', label: 'Language', limit: true
 #N   config.add_facet_field 'lc_1letter_facet', label: 'Call Number'
 #N   config.add_facet_field 'subject_geo_facet', label: 'Region'
 #N   config.add_facet_field 'subject_era_facet', label: 'Era'

 #N   config.add_facet_field 'example_pivot_field', label: 'Pivot Field', :pivot => ['format', 'language_facet']

 #N   config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
 #N      :years_5 => { label: 'within 5 Years', fq: "pub_date:[#{Time.zone.now.year - 5 } TO *]" },
 #N      :years_10 => { label: 'within 10 Years', fq: "pub_date:[#{Time.zone.now.year - 10 } TO *]" },
 #N      :years_25 => { label: 'within 25 Years', fq: "pub_date:[#{Time.zone.now.year - 25 } TO *]" }
 #N   }


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'author_id_ssi', :label => 'Forfatter', helper_method: :author_link, short_form: true, itemprop: :author
    ## if we have no author_id_ssi (link to author portrait, just show the author name)
    config.add_index_field 'author_name_tesim', :label => 'Forfatter',  short_form: true, itemprop: :author, unless: proc {|_context, _field_config, doc| doc['author_id_ssi'].present?}
    config.add_index_field 'volume_title_tesim', :label => 'Anvendt udgave', helper_method: :show_volume, short_form: true, itemprop: :isPartOf, unless: proc { |_context, _field_config, doc | doc.id == doc['volume_id_ssi'] }
    config.add_index_field 'editor_ssi', :label => 'Redaktør', itemprop: :editor

 #N   config.add_index_field 'title_display', label: 'Title'
 #N   config.add_index_field 'title_vern_display', label: 'Title'
 #N   config.add_index_field 'author_display', label: 'Author'
 #N   config.add_index_field 'author_vern_display', label: 'Author'
 #N   config.add_index_field 'format', label: 'Format'
 #N   config.add_index_field 'language_facet', label: 'Language'
 #N   config.add_index_field 'published_display', label: 'Published'
 #N   config.add_index_field 'published_vern_display', label: 'Published'
 #N   config.add_index_field 'lc_callnum_display', label: 'Call number'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display


    # Work show fields
    config.add_show_field 'author_id_ssi', :label => 'Forfatter', helper_method: :author_link, itemprop: :author
    config.add_show_field 'volume_title_tesim', :label => 'Anvendt udgave', helper_method: :show_volume, itemprop: :isPartOf, unless: proc { |_context, _field_config, doc | doc.id == doc['volume_id_ssi'] }
    config.add_show_field 'volume_title_ssi', :label => 'Citér dette værk', helper_method: :citation, unless: proc { |_context, _field_config, doc | doc.id == doc['volume_id_ssi'] }
    #config.add_show_field 'publisher_tesim', :label => 'Udgiver', unless: proc { |_context, _field_config, doc | doc['cat_ssi'] == 'volume' }
    #config.add_show_field 'place_published_tesim', :label => 'Udgivelsessted'
    #config.add_show_field 'date_published_ssi', :label => 'Udgivelsesdato'

    #add_show_tools_partial(:feedback, callback: :email_action, if: :render_feedback_action?)
    #config.show.document_actions.email.if = :render_email_action?
    config.show.document_actions.citation.if = :render_citation_action?

 #N  config.add_show_field 'title_display', label: 'Title'
 #N   config.add_show_field 'title_vern_display', label: 'Title'
 #N   config.add_show_field 'subtitle_display', label: 'Subtitle'
 #N   config.add_show_field 'subtitle_vern_display', label: 'Subtitle'
 #N   config.add_show_field 'author_display', label: 'Author'
 #N   config.add_show_field 'author_vern_display', label: 'Author'
 #N   config.add_show_field 'format', label: 'Format'
 #N   config.add_show_field 'url_fulltext_display', label: 'URL'
 #N   config.add_show_field 'url_suppl_display', label: 'More Information'
 #N   config.add_show_field 'language_facet', label: 'Language'
 #N   config.add_show_field 'published_display', label: 'Published'
 #N   config.add_show_field 'published_vern_display', label: 'Published'
 #N   config.add_show_field 'lc_callnum_display', label: 'Call number'
 #N   config.add_show_field 'isbn_t', label: 'ISBN'


    # Overwriting this method to enable pdf generation using WickedPDF
    # Unfortunately the additional_export_formats method was quite difficult
    # to use for this use case.

    def show
      @response, @document = search_service.fetch URI.unescape(params[:id])

      # if we are showing a volume, fetch list of all works in the volume
      if @document['cat_ssi'].starts_with? 'volume'
        (@work_resp, @work_docs) =  search_service.search_results() do |builder|
          if respond_to? (:blacklight_config)
            builder = blacklight_config.search_builder_class.new([:default_solr_parameters,:part_of_volume_search],builder)
            builder = builder.with({volumeid: @document['volume_id_ssi']})
            builder
          end
        end
      end

      #if we are showing a period, fetch a list of authors
      if @document['cat_ssi'].starts_with? 'period'
        (@auth_resp, @auth_docs) = search_service.search_results() do |builder|
          if respond_to? (:blacklight_config)
            builder = blacklight_config.search_builder_class.new([:default_solr_parameters,:build_authors_in_period_search],builder)
            builder = builder.with({perioid: @document['id']})
            builder
          end
        end
      end

      respond_to do |format|
        format.html { setup_next_and_previous_documents }
        format.json { render json: { response: { document: @document } } }
        format.pdf { send_pdf(@document, 'text') }
        format.xml do
          if @document['cat_ssi'] == 'volume'
            data = FileServer.get_file("/texts/#{@document['volume_id_ssi']}.xml")
            send_data data, type: 'application/xml'
          end
        end
        additional_export_formats(@document, format)
      end
    end

    def facsimile
      @response, @document = search_service.fetch URI.unescape(params[:id])
      respond_to do |format|
        format.html { setup_next_and_previous_documents }
        format.pdf { send_pdf(@document, 'image') }
      end
    end

    def periods
      (@response, @document_list) = search_service.search_results() do |builder|
        search_builder_class.new([:default_solr_parameters,:build_all_periods_search],builder)
      end
      render "index"
    end

    def authors
      (@response, @document_list) = search_service.search_results() do |builder|
        search_builder_class.new([:default_solr_parameters,:build_all_authors_search],builder)
      end
      render "index"
    end

    def allworks
      (@response, @document_list) = search_service.search_results()
      render "index"
    end


    # common method for rendering pdfs based on wicked_pdf
    # cache files in the public folder based on their id
    # perhaps using the Solr document modified field
    def send_pdf(document, type)
      name = document['work_title_tesim'].first.strip rescue document.id
      path = Rails.root.join('public', 'pdfs', "#{document.id.gsub('/', '_')}_#{type}.pdf")
      solr_timestamp = Time.parse(document['timestamp'])
      file_mtime = File.mtime(path) if File.exist? path.to_s
      # display the cached pdf if solr doc timestamp is older than the file's modified date
      if File.exist? path.to_s and ((type == 'text' and solr_timestamp < file_mtime) or type == 'image')
        send_file path.to_s, type: 'application/pdf', disposition: :inline, filename: name+".pdf"
      else
        render pdf: name,
               footer: {right: '[page] af [topage] sider'},
               save_to_file: path,
               header: {html: {template: 'shared/pdf_header.pdf.erb'},
                        spacing: 5},
               margin: {top: 15, # default 10 (mm)
                        bottom: 15},
               cover:  Rails.root.join('app', 'views', 'shared', 'pdf_cover.html')
        # If dynamic information is needed, it can come either from the snippet_server or by creating a string
        # here as:
        # cover:  'Hentet fra ADL. Forfatter: ' + document['author_name_ssi']
      end
    end

    # we do not want to start a new search_session for 'leaf' searches
    # to avoid messing up previous and next links
    def start_new_search_session?
      action_name == "index" && params['search_field'] != 'leaf'
    end

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('Alt',label: I18n.t('blacklight.search.form.search.all_filters')) do |field|
      field.solr_parameters = {
          :fq => ['application_ssim:ADL','cat_ssi:work','type_ssi:trunk']
      }
      field.solr_local_parameters = {
          :qf => 'author_name_tesim^5 work_title_tesim^5 text_tesim'
      }
    end

    config.add_search_field('title', label: I18n.t('blacklight.search.form.search.title')) do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
          :fq => ['application_ssim:ADL','cat_ssi:work','type_ssi:trunk'],
          :'spellcheck.dictionary' => 'title'
      }
      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
          :qf => 'work_title_tesim',
      }
    end

    config.add_search_field('author', label: I18n.t('blacklight.search.form.search.author')) do |field|
      field.solr_parameters = {
          :fq => ['application_ssim:ADL','cat_ssi:work','type_ssi:trunk'],
          :'spellcheck.dictionary' => 'author'
      }
      field.solr_local_parameters = {
          :qf => 'author_name_tesim',
      }
    end

    config.add_search_field('leaf') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = { :fq => 'type_ssi:leaf' }
      field.solr_local_parameters = {
          :qf => 'text_tesim',
          :pf => 'text_tesim',
          :hl => 'true',
      }
    end

    config.add_search_field('oai_time') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
          :fq => 'cat_ssi:work'
      }
      field.solr_local_parameters = {
          :fl => 'timestamp'
      }
    end


    config.add_search_field('oai_search') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
          :fq => 'cat_ssi:work'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc', :label => (I18n.t'blacklight.search.form.sort.relevance')
    config.add_sort_field 'author_name_ssi asc', :label => (I18n.t'blacklight.search.form.sort.author')
    config.add_sort_field 'work_title_ssi asc', :label => 'Titel'

    config.spell_max = 5




 #N   config.add_search_field 'all_fields', label: 'All Fields'


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

#N    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
#N      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
#N      field.solr_local_parameters = {
#N        qf: '$title_qf',
#N        pf: '$title_pf'
#N      }

 #N   config.add_search_field('author') do |field|
 #N     field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
 #N     field.solr_local_parameters = {
 #N       qf: '$author_qf',
 #N       pf: '$author_pf'
 #N     }
 #N   end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
 #N   config.add_search_field('subject') do |field|
 #N     field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
 #N     field.qt = 'search'
 #N     field.solr_local_parameters = {
 #N       qf: '$subject_qf',
 #N       pf: '$subject_pf'
 #N     }
 #N   end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
 #N   config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', label: 'relevance'
 #N   config.add_sort_field 'pub_date_sort desc, title_sort asc', label: 'year'
 #N   config.add_sort_field 'author_sort asc, title_sort asc', label: 'author'
 #N   config.add_sort_field 'title_sort asc, pub_date_sort desc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
 end

  def oai
    options = params.delete_if { |k,v| %w{controller action}.include?(k) }
    p = oai_provider
    render :text => p.process_request(options), :content_type => 'text/xml'
  end

  def oai_provider
    @oai_provider ||= ::AdlDocumentProvider.new(self)
  end


 # Email Action (this will render the appropriate view on GET requests and process the form and send the email on POST requests)
  def email_action documents
    report = params[:report].nil? ? "" : params[:report]
    report +=  I18n.t('blacklight.email.text.from', value: current_user.email) + "\n" unless current_user.nil?
    mail = RecordMailer.email_record(documents, {:to => params[:to], :message => report+"\n\n"+params[:message]}, url_options)
    if mail.respond_to? :deliver_now
      mail.deliver_now
    else
      mail.deliver
    end
  end


  def feedback
    @response, @document = search_service.fetch URI.unescape(params[:id])
    @report = ""
    @report +=  I18n.t('blacklight.email.text.from', value: current_user.email) + "\n" unless current_user.nil?
    @report +=  I18n.t('blacklight.email.text.url', url: @document['url_ssi']) + "\n" unless @document['url_ssi'].blank?
    @report += I18n.t('blacklight.email.text.author', value: @document['author_name'].first) + "\n" unless @document['author_name'].blank?
    @report += I18n.t('blacklight.email.text.title', value: @document['work_title_tesim'].first.strip)+ "\n" unless @document['work_title_tesim'].blank?
    render layout: nil
  end

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


  # actions for generating the list of authorportraits and period descriptions

  def periods
    periods_search_service = search_service_class.new(blacklight_config, search_state.to_h)
    # Search for period descriptions
    # Use a search builder with special processing chain
    (@response, deprecated_document_list) = periods_search_service.search_results do |builder|
      periods_search_service.search_builder_class.new([:default_solr_parameters,:build_all_periods_search],builder)
    end
    render "index"
  end

  def authors
    authors_search_service = search_service_class.new(blacklight_config, search_state.to_h)
    # Search for period descriptions
    # Use a search builder with special processing chain
    (@response, deprecated_document_list) = authors_search_service.search_results do |builder|
      authors_search_service.search_builder_class.new([:default_solr_parameters,:build_all_authors_search],builder)
    end
    render "index"
  end



end
