class Kid < ActiveRecord::Base
  before_validation :create_full_address
  before_validation :generate_image_url

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :missing_state
  validates_presence_of :image_url

  geocoded_by :address
  before_save :geocode, :if => :address_changed?

  default_scope -> { where("age > 0") }

  def full_name
    "#{self.first_name} #{self.middle_name} #{last_name}"
  end

  def create_full_address
    unless self.missing_city.blank? && self.missing_state.blank?
      self.address = "#{self.missing_city}, #{self.missing_state}"
    else
      self.address = self.missing_state
    end
  end

  def add_hostname_to_url(hostname, url)
    base = self.send(url.to_sym)
    self.send("#{url.to_sym}=",  "#{hostname}#{base}")
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^fullname$/
      self.full_name
    else
      super
    end
  end

  def generate_image_url
    if self.thumbnail_url
      self.image_url = self.thumbnail_url.gsub(/t\./, ".")
    end
  end

  def missing_url
    "http://www.missingkids.com/missingkids/servlet/PubCaseSearchServlet?act=viewPoster&caseNum=#{self.case_number}&orgPrefix=#{self.org_prefix}"
  end

  def increment(by = 1)
    self.views ||= 0
    self.views += by
    self.save
  end

  def description
    "#{full_name.upcase}, AGE: #{age}, MISSING: #{missing_date}"
  end
end
