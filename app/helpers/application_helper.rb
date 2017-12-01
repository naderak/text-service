# -*- coding: utf-8 -*-
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

  def construct_citation args
    label = []
    author = args[:document]['author_name_ssi'] + ": " if args[:document]['author_name_ssi'].present?
    title = args[:document]['volume_title_tesim'].try(:first).to_s
    # Add author and value as one string so they don't get separated by comma
    label << author + title
    label << "udg. af #{args[:document]['editor_ssi']}" if args[:document]['editor_ssi'].present?
    label << "#{args[:document]['publisher_tesim'].join(', ')}" if args[:document]['publisher_tesim'].present?
    label << "#{args[:document]['date_published_ssi']}" if args[:document]['date_published_ssi'].present?
    # Remove empty string from the array
    label = label.reject { |c| c.empty? }
    return label.to_sentence(last_word_connector: ", ")
  end

  def show_volume args
    id = args[:document]['volume_id_ssi']
    return unless id.present?
    udgave = construct_citation(args)+"."
    link_to udgave, solr_document_path(id)
  end

  def citation args
    # Construct the first part and add the anvendt udgave and the page number
    cite = ""
    cite += args[:document]['author_name_ssi'] + ": " if args[:document]['author_name_ssi'].present?
    cite += ">>"+args[:document]['work_title_tesim'].first+"<<, i " if args[:document]['work_title_tesim'].present?
    cite += construct_citation(args)
    cite += ", s. "+args[:document]['page_ssi'] if args[:document]['page_ssi'].present?
    cite += ". "
    # Add the URL and the date in the string
    cite += 'Online udgave fra "Arkiv for Dansk Litteratur (ADL)": ' + request.original_url
    # There must be a smarter way to get the months translated
    cite += " (tilgået " + Time.now.strftime("%d. ")
    cite += I18n.t(Time.now.strftime('%B'))
    cite += Time.now.strftime(' %Y') +")"
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

  def get_author_image(id)
    "authors/#{id.gsub('adl-authors-','').gsub('-root','')}.jpg"
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
