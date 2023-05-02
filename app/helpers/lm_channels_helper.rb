module LmChannelsHelper

  def tp_channel_prefix_name_helper(lm_channel)
    dictionary_map = {"tp2" => "Теплопункт №2", "tp3" => "Теплопункт №3", "tp4" => "Теплопункт №4",
      "tp5" => "Теплопункт №5", "tp6" => "Теплопункт №6", "tp7" => "Теплопункт №7"}
    dictionary_map[lm_channel.prefix]
  end

end
