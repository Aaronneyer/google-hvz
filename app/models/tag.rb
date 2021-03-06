class Tag < ActiveRecord::Base

  belongs_to :tagger, class_name: Player
  belongs_to :tagee, class_name: Player

  validate :validate_tagger
  validate :validate_tagee
  validate :validate_time

  after_create :zombify
  after_create :award_points, unless: :admin_tag
  
  def tag_code=(tag_code)
    self.tagee = Player.find_by(tag_code: tag_code.upcase)
  end

  def tag_code
    #This is dumb, but I don't have documentation on the airplane
  end

  def validate_tagee
    unless tagee
      errors.add(:tag_code, 'No player was found with that tag code.')
      return
    end
    errors.add(:tag_code, 'Is for a zombie') if tagee.zombie?
    errors.add(:tag_code, 'Is for someone in another game') unless tagee.game == Game.current
  end

  def validate_tagger
    return if admin_tag
    unless tagger
      errors.add(:tagger, 'Must not be nil')
      return
    end
    errors.add(:tagger, 'Must be a zombie') unless tagger.zombie?
    errors.add(:tagger, 'Must be in the current game') unless tagger.game == Game.current
  end

  def validate_time
    errors.add(:time, 'Must not be in the future') if time.future?
  end

  def zombify
    tagee.update_attribute(:faction, Player::ZOMBIE)
  end

  def award_points
    tagger.increment!(:score, 2)
  end
end
