# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  def build_all_periods_search solr_params = {}
    solr_params[:fq] = []
    solr_params[:fq] << 'cat_ssi:period AND type_ssi:work'
    solr_params[:sort] = []
    solr_params[:sort] << 'sort_title_ssi asc'
    solr_params[:rows] = 10000
  end

end
