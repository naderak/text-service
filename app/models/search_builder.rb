# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end

  self.default_processor_chain += [:restrict_to_author_id, :add_work_id, :add_timestamp_interval, :more_search_params]

  def add_work_id solr_params
    if blacklight_params[:search_field] == 'leaf' && blacklight_params[:workid].present?
      solr_params[:fq] ||= []
      workid = blacklight_params[:workid]
      workid = "#{workid}*" unless workid.include? '*'
      # sorting in document order
      solr_params[:sort] = []
      solr_params[:sort] << 'position_isi asc'
      # part of search
      solr_params[:fq] << "part_of_ssim:#{workid}"
    end
  end

  def restrict_to_author_id solr_params
    if (blacklight_params[:authorid].present?)
      solr_params[:fq] ||= []
      solr_params[:fq] << "author_id_ssi:#{blacklight_params[:authorid]}"
      solr_params[:fq] << "cat_ssi:work"
    end
  end

  def part_of_volume_search solr_params
    solr_params[:fq] = []
    solr_params[:fq] << "cat_ssi:work"
    solr_params[:fq] << "volume_id_ssi:#{blacklight_params[:volumeid]}"
    solr_params[:rows] = 10000

  end

  def build_authors_in_period_search solr_params = {}
    solr_params[:fq] = []
    solr_params[:fq] << 'cat_ssi:author'
    solr_params[:fq] << "perioid_ssi:#{blacklight_params[:perioid]}"
    solr_params[:sort] = []
    solr_params[:sort] << 'work_title_ssi asc'
    solr_params[:rows] = 10000
  end

  def add_timestamp_interval solr_params
    timeinterval_string = '['+ (blacklight_params[:from].present? ? blacklight_params[:from] : '*')
    timeinterval_string += ' TO '
    timeinterval_string += (blacklight_params[:until].present? ? blacklight_params[:until] : '*') +']'
    solr_params[:fq] ||= []
    solr_params[:fq] << "timestamp:#{timeinterval_string}"
  end

  def more_search_params solr_params
    # this is not the optimal way of doing phrase search, but i have not find the right solr params
    if blacklight_params['match'] == 'phrase'
      solr_params['q'] = "\"#{solr_params['q']}\""
      solr_params['qs'] = 0
    end
    if blacklight_params['match'] == 'all'
      solr_params[:mm] = '100%'
    end
    if blacklight_params['match'] == 'one' || !blacklight_params['match'].present?
      solr_params[:mm] = 1
    end
    solr_params
  end
end
