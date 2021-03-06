#==============================================================================
# ■ Regular Expression
#==============================================================================

module REGEXP
  module SYMPHONY
    SETUP_ANI_ON   = /<(?:SETUP_ACTION|setup action|setup)>/i
    SETUP_ANI_OFF  = /<\/(?:SETUP_ACTION|setup action|setup)>/i
    WHOLE_ANI_ON   = /<(?:WHOLE_ACTION|whole action|whole)>/i
    WHOLE_ANI_OFF  = /<\/(?:WHOLE_ACTION|whole action|whole)>/i
    TARGET_ANI_ON  = /<(?:TARGET_ACTION|target action|target)>/i
    TARGET_ANI_OFF = /<\/(?:TARGET_ACTION|target action|target)>/i
    FOLLOW_ANI_ON  = /<(?:FOLLOW_ACTION|follow action|follow)>/i
    FOLLOW_ANI_OFF = /<\/(?:FOLLOW_ACTION|follow action|follow)>/i
    FINISH_ANI_ON  = /<(?:FINISH_ACTION|finish action|finish)>/i
    FINISH_ANI_OFF = /<\/(?:FINISH_ACTION|finish action|finish)>/i
    
    SYMPHONY_TAG_NONE = /[ ]*(.*)/i
    SYMPHONY_TAG_VALUES = /[ ]*(.*):[ ]*(.*)/i
    
    ATK_ANI1 = /<(?:ATK_ANI_1|atk ani 1):[ ]*(\d+)>/i
    ATK_ANI2 = /<(?:ATK_ANI_2|atk ani 2):[ ]*(\d+)>/i

  end
end

# Scan values: /\w+[\s*\w+]*/i

#==============================================================================
# ■ DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_bes load_database; end
  def self.load_database
    load_database_bes
    load_notetags_bes
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_bes
  #--------------------------------------------------------------------------
  def self.load_notetags_bes
    groups = [$data_skills, $data_items, $data_weapons, $data_enemies]
    groups.each { |group|
      group.each { |obj|
        next if obj.nil?
        obj.battle_symphony_initialize
      }
    }
  end
  
end # DataManager

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :setup_actions_list 
  attr_accessor :whole_actions_list
  attr_accessor :target_actions_list
  attr_accessor :follow_actions_list
  attr_accessor :finish_actions_list
  attr_accessor :atk_animation_id1
  attr_accessor :atk_animation_id2
  
  #--------------------------------------------------------------------------
  # new method: battle_symphony_initialize
  #--------------------------------------------------------------------------
  def battle_symphony_initialize
    create_default_animation
    create_default_symphony
    create_tags_symphony
  end
  
  #--------------------------------------------------------------------------
  # new method: create_default_animation
  #--------------------------------------------------------------------------
  def create_default_animation
    @atk_animation_id1 = SYMPHONY::Visual::ENEMY_ATTACK_ANIMATION
    @atk_animation_id2 = 0
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::SYMPHONY::ATK_ANI1
        @atk_animation_id1 = $1.to_i
      when REGEXP::SYMPHONY::ATK_ANI2
        @atk_animation_id2 = $1.to_i
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: create_default_symphony
  #--------------------------------------------------------------------------
  def create_default_symphony
    @setup_actions_list = []; @finish_actions_list = []
    @whole_actions_list = []; @target_actions_list = []
    @follow_actions_list = []
    #---
    if self.is_a?(RPG::Skill) and !self.physical?
      @setup_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_SETUP
      @whole_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_WHOLE
      @target_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_TARGET
      @follow_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_FOLLOW
      @finish_actions_list = SYMPHONY::DEFAULT_ACTIONS::MAGIC_FINISH
      return
    elsif self.is_a?(RPG::Skill) and self.physical?
      @setup_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_SETUP
      @whole_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_WHOLE
      @target_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_TARGET
      @follow_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_FOLLOW
      @finish_actions_list = SYMPHONY::DEFAULT_ACTIONS::PHYSICAL_FINISH
      return
    elsif self.is_a?(RPG::Item)
      @setup_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_SETUP
      @whole_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_WHOLE
      @target_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_TARGET
      @follow_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_FOLLOW
      @finish_actions_list = SYMPHONY::DEFAULT_ACTIONS::ITEM_FINISH
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: create_tags_symphony
  #--------------------------------------------------------------------------
  def create_tags_symphony
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when REGEXP::SYMPHONY::SETUP_ANI_ON
        @symphony_tag = true
        @setup_actions_list = []
        @setup_action_flag = true
      when REGEXP::SYMPHONY::SETUP_ANI_OFF
        @symphony_tag = false
        @setup_action_flag = false
      when REGEXP::SYMPHONY::WHOLE_ANI_ON
        @symphony_tag = true
        @whole_actions_list = []
        @whole_action_flag = true
      when REGEXP::SYMPHONY::WHOLE_ANI_OFF
        @symphony_tag = false
        @whole_action_flag = false
      when REGEXP::SYMPHONY::TARGET_ANI_ON
        @symphony_tag = true
        @target_actions_list = []
        @target_action_flag = true
      when REGEXP::SYMPHONY::TARGET_ANI_OFF
        @symphony_tag = false
        @target_action_flag = false
      when REGEXP::SYMPHONY::FOLLOW_ANI_ON
        @symphony_tag = true
        @follow_actions_list = []
        @follow_action_flag = true
      when REGEXP::SYMPHONY::FOLLOW_ANI_OFF
        @symphony_tag = false
        @follow_action_flag = false
      when REGEXP::SYMPHONY::FINISH_ANI_ON
        @symphony_tag = true
        @finish_actions_list = []
        @finish_action_flag = true
      when REGEXP::SYMPHONY::FINISH_ANI_OFF
        @symphony_tag = false
        @finish_action_flag = false
      #---
      else
        next unless @symphony_tag
        case line
        when REGEXP::SYMPHONY::SYMPHONY_TAG_VALUES
          action = $1
          value = $2.scan(/[^, ]+[^,]*/i)
        when REGEXP::SYMPHONY::SYMPHONY_TAG_NONE
          action = $1
          value = [nil]
        else; next
        end
        array = [action, value]
        if @setup_action_flag
          @setup_actions_list.push(array)
        elsif @whole_action_flag
          @whole_actions_list.push(array)
        elsif @target_action_flag
          @target_actions_list.push(array)
        elsif @follow_action_flag
          @follow_actions_list.push(array)
        elsif @finish_action_flag
          @finish_actions_list.push(array)
        end
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # new method: valid_actions?
  #--------------------------------------------------------------------------
  def valid_actions?(phase)
    case phase
    when :setup
      return @setup_actions_list.size > 0
    when :whole
      return @whole_actions_list.size > 0
    when :target
      return @target_actions_list.size > 0
    when :follow
      return @follow_actions_list.size > 0
    when :finish
      return @finish_actions_list.size > 0
    end
  end
  
end # RPG::BaseItem