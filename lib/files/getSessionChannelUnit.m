function [session, channel, unit] = getSessionChannelUnit(id)
    session = str2double(id(1:6));
    channel = str2double(id(7:9));
    unit = str2double(id(10));
end