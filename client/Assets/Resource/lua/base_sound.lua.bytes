

local  Class = {

}


function Class:play_music(v)

    if v  == nil then
        v = self.music_res
    else
        self.music_res = v
    end

    --print(self.music)

    if self.music > 0 then
        GameAPI.PlayMusic(v,self.music)
    end
end

function Class:change_music_value(value)
    GameAPI.ChangeMusicValue(value)
end

function Class:stop_music()
    GameAPI.StopMusic()
end


function Class:play_sound(v)
    if self.effect > 0 then
        GameAPI.PlaySound(v,self.effect)
    end
end

function Class:play_vibrate(v)
    if self.vibrate then
    end
end



return Class
