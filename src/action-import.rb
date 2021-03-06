#==============================================================================
# ■ Scene_Battle - Imported Symphony Configuration
#==============================================================================
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # new method: imported_symphony
  #--------------------------------------------------------------------------
  def imported_symphony
    case @action.upcase
      
      #--- Start Importing ---
      
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      # sample symphony
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # This is the most basic sample, it will put a line which contains 
      # action name and action values in Console.
      #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      when /SAMPLE SYMPHONY/i
        action_sample_symphony
      
      #--- End Importing ---
      else
        if SYMPHONY::AUTO_SYMPHONY.include?(@action.upcase)
          @action_values = [@action.upcase]
          @action = "AUTO SYMPHONY"
          action_autosymphony
        end
    end
  end

end # Scene_Battle
#==============================================================================
# ■ Scene_Battle - Imported Symphony Actions
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: action_sample_symphony
  #--------------------------------------------------------------------------
  def action_sample_symphony
    str = "#{@action.upcase}: "
    @action_values.each {|value| str += "#{value} "}
    puts str
  end
  
end # Scene_Battle