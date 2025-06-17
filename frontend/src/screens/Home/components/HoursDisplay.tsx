import React, { useState, useEffect, useRef } from 'react';
import { Animated, Easing } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { styled } from 'nativewind';
import { View, Text, TouchableOpacity } from 'react-native';

const StyledView = styled(Animated.View);
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

  const [rawOpen, rawClose] = timeRange.split(' – ');
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
  const ordered = rotateHoursFromToday(hours);
  const animatedValues = useRef<Animated.Value[]>([]);
  const [visibleRows, setVisibleRows] = useState(0);

  // Initialize one Animated.Value per line (except first row)
  if (animatedValues.current.length !== ordered.length - 1) {
    animatedValues.current = Array(ordered.length - 1)
      .fill(null)
      .map(() => new Animated.Value(0));
  }

  useEffect(() => {
    if (isExpanded) {
      setVisibleRows(0); // reset before expanding

      const timers = animatedValues.current.map((_, idx) => {
        return setTimeout(() => {
          setVisibleRows((prev) => prev + 1);
          Animated.timing(animatedValues.current[idx], {
            toValue: 1,
            duration: 300,
            easing: Easing.out(Easing.ease),
            useNativeDriver: true,
          }).start();
        }, idx * 90);
      });

      return () => timers.forEach(clearTimeout);
    } else {
      animatedValues.current.forEach((anim) => anim.setValue(0));
      setVisibleRows(0);
    }
  }, [isExpanded]);

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
        <StaticView className="w-[46%]">
          {ordered.map((line, idx) => {
            if (idx === 0) {
              return (
                <StyledTouchableOpacity
                  key={idx}
                  onPress={onToggle}
                  className="flex-row items-center justify-start gap-2"
                >
                  <Icon name="access-time" size={18} color="gray" />
                  <StyledText className="text-xs text-gray-700 font-system">{line}</StyledText>
                </StyledTouchableOpacity>
              );
            }

            // only render this row if visible
            if (idx > visibleRows) return null;

            const opacityAnim = animatedValues.current[idx - 1];

            return (
              <Animated.View
                key={idx}
                style={{
                  opacity: opacityAnim,
                  transform: [
                    {
                      translateY: opacityAnim.interpolate({
                        inputRange: [0, 1],
                        outputRange: [-8, 0],
                      }),
                    },
                  ],
                }}
                className="mt-1"
              >
                <StyledTouchableOpacity
                  onPress={onToggle}
                  className="flex-row items-center justify-start gap-2"
                >
                  <StyledText className="text-xs text-gray-700 font-system">{line}</StyledText>
                </StyledTouchableOpacity>
              </Animated.View>
            );
          })}
        </StaticView>
      )}
    </StaticView>
  );
};

export default HoursDisplay;
