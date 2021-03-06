module ChatBot
  class Category
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Slug

    include Mongoid::History::Trackable
    track_history :on => [:fields],
                  :modifier_field => :modifier


    field :name, type: String

    has_many :sub_categories, class_name: 'ChatBot::SubCategory'

    slug :name

    index({_slug: 1})

    validates :name, presence: true, uniqueness: {case_sensitive: false}

    before_validation :squish_name, if: "name.present?"

    def squish_name
      ## We need both capitalize & titleiz bcz
      ##  it does't work using only one of them in following example
      ## "applIcatioN inTRoductiON"
      ## "Appl Icatio N In T Roducti On"
      self.name = name.squish.capitalize.titleize
    end

  end
end
