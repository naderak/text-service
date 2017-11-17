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

  self.default_processor_chain += [:restrict_to_author_id, :add_work_id, :add_timestamp_interval]

  def add_work_id solr_params
    if blacklight_params[:search_field] == 'leaf' && blacklight_params[:workid].present?
      solr_params[:fq] ||= []
      workid = blacklight_params[:workid]
      workid = "#{workid}*" unless workid.include? '*'
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

  def build_all_authors_search solr_params = {}
    solr_params[:fq] = []
    solr_params[:fq] << 'cat_ssi:author'
    solr_params[:fq] << 'type_ssi:work'
    solr_params[:sort] = []
    solr_params[:sort] << 'sort_title_ssi asc'
    solr_params[:rows] = 10000
  end

  def build_all_periods_search solr_params = {}
    solr_params[:fq] = []
    solr_params[:fq] << 'cat_ssi:period'
    solr_params[:sort] = []
    solr_params[:sort] << 'sort_title_ssi asc'
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
end
