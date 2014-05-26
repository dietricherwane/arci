def self.create_index_with_mappings
  Tire.index Settings.elasticsearch_user_index do
    create :mappings => {
      :user => {
        :properties => {
          :id => { :type => 'integer', :analyzer => 'keyword', :include_in_all => false },
          :name => {:type => 'string', :analyzer => 'snowball', :boost => 100},
          :description => { :type => 'string', :analyzer => 'snowball' },
          :description_manual => { :type => 'string', :analyzer => 'snowball' },
          :language => { :type => 'string', :analyzer => 'keyword'}
        }
      }
    }
  end
 end
