import React, { useState, useEffect } from 'react';
import { Animated, Easing } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { styled } from 'nativewind';
import { View, Text, TouchableOpacity } from 'react-native';

const StyledView = styled(Animated.View); // Use Animated.View for smooth fade
const StaticView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledText = styled(Text);

const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

export const rotateHoursFromToday = (hours: string[]): string[] => {
  const todayIndex = new Date().getDay();
  const ordered: string[] = [];
  for (let i = 0; i < 7; i++) {
    const index = (todayIndex + i) % 7;
    const match = hours.find((line) => line.startsWith(days[index]));
    if (match) ordered.push(match);
  }
  return ordered;
};

export const getTodayHours = (hours: string[]) => {
  const today = days[new Date().getDay()];
  const todayLine = hours.find((line) => line.startsWith(today));
  if (!todayLine || todayLine.toLowerCase().includes('closed')) return 'Closed';

  const timeRange = todayLine.split(': ')[1];
  if (!timeRange) return todayLine;

  const [rawOpen, rawClose] = timeRange.split(' – '); // \u2009 narrow space
  const now = new Date();

  const parseTime = (str: string, fallbackAMPM?: string): Date => {
    const ampmMatch = str.match(/(AM|PM)/i);
    let timeStr = str.trim();
    if (!ampmMatch && fallbackAMPM) timeStr += ` ${fallbackAMPM}`;

    const [time, modifier] = timeStr.split(/\s+/);
    const [hours, minutes] = time.split(':').map(Number);
    let hrs = hours;
    if (modifier?.toUpperCase() === 'PM' && hours < 12) hrs += 12;
    if (modifier?.toUpperCase() === 'AM' && hours === 12) hrs = 0;

    const parsed = new Date(now);
    parsed.setHours(hrs, minutes || 0, 0, 0);
    return parsed;
  };

  const closeAMPM = rawClose.match(/AM|PM/i)?.[0];
  const openTime = parseTime(rawOpen, closeAMPM);
  const closeTime = parseTime(rawClose);

  const msUntilOpen = openTime.getTime() - now.getTime();
  const msUntilClose = closeTime.getTime() - now.getTime();

  if (msUntilOpen > 0 && msUntilOpen <= 60 * 60 * 1000) {
    return `Opens soon at ${rawOpen}`;
  }
  if (msUntilClose > 0 && msUntilClose <= 60 * 60 * 1000) {
    return `Closes soon at ${rawClose}`;
  }
  if (now >= openTime && now < closeTime) {
    return `Open now, until ${rawClose}`;
  }

  return todayLine;
};

const HoursDisplay = ({
  isExpanded,
  hours,
  onToggle,
}: {
  isExpanded: boolean;
  hours: string[];
  onToggle: () => void;
}) => {
  const [fadeAnim] = useState(new Animated.Value(isExpanded ? 1 : 0));

  useEffect(() => {
    Animated.timing(fadeAnim, {
      toValue: isExpanded ? 1 : 0,
      duration: 200,
      easing: Easing.out(Easing.ease),
      useNativeDriver: true,
    }).start();
  }, [isExpanded]);

  const ordered = rotateHoursFromToday(hours);

  return (
    <StaticView className="items-center">
      {!isExpanded ? (
        <StaticView className="h-[20px] w-[46%]">
          <StyledTouchableOpacity
            onPress={onToggle}
            className="flex-row items-center justify-start gap-2"
          >
            <Icon name="access-time" size={18} color="gray" />
            <StyledText className="text-xs text-gray-700 font-system">
              {getTodayHours(hours) ?? "Today's hours not found"}
            </StyledText>
          </StyledTouchableOpacity>
        </StaticView>
      ) : (
        <StyledView
          style={{
            opacity: fadeAnim,
            transform: [
              {
                translateY: fadeAnim.interpolate({
                  inputRange: [0, 1],
                  outputRange: [-10, 0],
                }),
              },
            ],
          }}
          className="w-[46%]"
        >
          {ordered.map((line, idx) => (
            <StyledTouchableOpacity
              key={idx}
              onPress={onToggle}
              className={`flex-row items-center justify-start gap-2 ${
                idx === 0 ? '' : 'mt-1'
              }`}
            >
              {idx === 0 && <Icon name="access-time" size={18} color="gray" />}
              <StyledText className="text-xs text-gray-700 font-system">{line}</StyledText>
            </StyledTouchableOpacity>
          ))}
        </StyledView>
      )}
    </StaticView>
  );
};

export default HoursDisplay;
