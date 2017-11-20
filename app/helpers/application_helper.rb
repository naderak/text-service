module ApplicationHelper

  def get_period_name value
    res = value
    if controller.present?
      begin
        resp, doc = controller.fetch(value)
        if doc['work_title_tesim'].present?
          res = doc['work_title_tesim'].join(' ')
        end
      rescue Exception => e
        logger.error("Could not get period name #{value} #{e.message}")
      end
    end
    res
  end

  def show_volume args
    id = args[:document]['volume_id_ssi']
    label = args[:document]['volume_title_tesim'].try(:first).to_s
    label += " (#{args[:document]['date_published_ssi']})" if args[:document]['date_published_ssi'].present?
    return unless id.present?
    link_to label, solr_document_path(id)
  end

  def author_link args
    ids = args[:value]
    logger.debug "Creating author_link #{args[:document]['author_name_tesim'].to_s}"
    if (ids.is_a? Array) && (ids.size > 1) # we have more than one author
      repository = blacklight_config.repository_class.new(blacklight_config)
      ids.map!{|id| link_to get_author_name(repository,id), solr_document_path(id)}
      result=ids.to_sentence(:last_word_connector => ' og ')
    else
      if ids.is_a? Array
        author_id = ids.first
      else
        author_id = ids
      end
      author_name = args[:document]['author_name_tesim'].first if args[:document]['author_name_tesim'].present?
      author_name ||= "Intet Navn"
      result = link_to author_name, solr_document_path(author_id)
    end
    logger.debug "result is #{result}"
    result
  end

  def translate_model_names(name)
    I18n.t("models.#{name}")
  end

  # Generic method to create glyphicon icons
  # supply only the last component of the icon name
  # e.g. 'off', 'cog' etc
  def bootstrap_glyphicon(icon, classes = '')
    content_tag(:span, nil, class: "glyphicon glyphicon-#{icon} #{classes}").html_safe
  end

  private

  def get_author_name repository, id
    begin
      solr_docs = repository.find(id).documents
      if solr_docs.size > 0
        solr_docs.first['work_title_tesim'].join
      else
        id
      end
    rescue Exception => e
      id
    end
  end
end
