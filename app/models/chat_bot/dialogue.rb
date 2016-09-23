module ChatBot
  class Dialogue
    include Mongoid::Document
    include Mongoid::Slug

    slug do |cur_object|
      cur_object.code.gsub('.', '_').to_url
    end

    RESPONSE_TYPES = { 'ch' => 'Choice', 'cnt' => 'Botcontinue',
                       'slt' => 'Single line text', 'mlt' => 'Multi line text',
                       'ddw' => 'Dropdown', 'date' => 'Date', 'attach' => 'Attach'}

    MESSAGE_TYPES = { 'txt' => 'TEXT', 'utube' => 'VIDEO:YOUTUBE',
                      'vimeo' => 'VIDEO:VIMEO', 'link' => 'LINK', 'img' => 'IMAGE'}

    field :code, type: String
    field :message, type: String
    field :user_input_type, type: String, default: 'ch'
    field :message_type, type: String, default: 'txt'

    has_many :options, class_name: 'ChatBot::Option', primary_key: :code, inverse_of: :dialogue
    belongs_to :sub_category, class_name: 'ChatBot::SubCategory'

    index({_slug: 1})

    validates :message, presence: true
    validates :user_input_type, inclusion: RESPONSE_TYPES.keys
    validates :message_type, inclusion: MESSAGE_TYPES.keys
    validates :sub_category, presence: true

    accepts_nested_attributes_for :options

    def self.generate_code(for_code = nil)
      if for_code.present?
        match_number = for_code.match(/^T(\d*)(\.(\d*))?$/)

        base, precision = match_number[1].to_i, match_number[3]
        precision = precision.to_i if precision.present? # We don't want nil or '' to convert to 0
        existing_codes = Dialogue.all.collect(&:code)

        # Logic will work as follows:
        # if for_code is T123.45 will return
        #   T124 if doesn't exists
        #   otherwise will return T123.46 if doens't exists
        #   otherwise will return T123.451 or T123.452 or T123.452... and so on

        case true
        when !existing_codes.include?("T#{base+1}")
          return "T#{base+1}"
        when (precision.present? and !existing_codes.include?("T#{base}.#{precision+1}"))
          return "T#{base}.#{precision+1}"
        else
          next_precision = "#{precision}1".to_i
          loop do
            next_code = "T#{base}.#{next_precision}"
            return next_code if !existing_codes.include?(next_code)
            next_precision += 1
          end
        end
      else
        "T#{all.collect{|d| d.code.split('.').first.gsub('T', '').to_i}.sort.last.to_i + 1}"
      end
    end

  end
end
