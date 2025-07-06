module EmailHelper
  def email_image_tag(image, **options)
    attachments.inline[image] = File.read(Rails.root.join('app', 'assets', 'images', image))
    options[:src] = attachments[image].url
    tag("img", **options)
  end
end
