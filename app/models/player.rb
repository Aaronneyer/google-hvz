class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  has_many :feeds

  validates :user_id, uniqueness: { scope: :game_id }

  ZOMBIE = 0
  HUMAN = 1
  DECEASED = 2

  def self.generate_code
    chars = %w(A B C D E F 1 2 3 4 5 6 7 8 9)
    code = 6.times.map{chars.sample}.join
    if Player.exists?(tag_code: code)
      return Player.generate_code
    else
      return code
    end
  end

  def faction_name
    case faction
    when ZOMBIE then "Zombie"
    when HUMAN then "Human"
    when DECEASED then "Deceased"
    end
  end

  def zombie?
    faction == ZOMBIE
  end

  def human?
    faction == HUMAN
  end

  def deceased?
    last_fed + 48.hours < Time.now
  end

  def last_feed
    feeds.order('time DESC').last
  end

  def last_fed
    if last_feed
      Time.now-last_feed.time
    else
      Time.now - game.start_time
    end
  end

  def starves_in
    48.hours - last_fed
  end

  def hours_to_starve
    if zombie?
      "under #{(starves_in/3600).ceil} hours"
    else
      "Staying alive!"
    end
  end

  def feed_label
    "#{user.name} (Starves in #{hours_to_starve})"
  end

  def zombify
    faction = ZOMBIE
  end
end
