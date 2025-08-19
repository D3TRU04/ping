// home/feeds/item-card/components/HoursDisplay.tsx
import React from 'react';
import { View, TouchableOpacity } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import AppText from '../../../../../components/AppText';
import { COLORS } from '../../../../../theme/colors';

const StyledView = styled(View);
const StyledTouchableOpacity = styled(TouchableOpacity);

const DAY_ORDER = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const DAY_SHORT = {
  Monday: 'Mon',
  Tuesday: 'Tue',
  Wednesday: 'Wed',
  Thursday: 'Thu',
  Friday: 'Fri',
  Saturday: 'Sat',
  Sunday: 'Sun',
};

const today = new Date();
const todayName = DAY_ORDER[today.getDay() === 0 ? 6 : today.getDay() - 1];

export function groupHours(hoursArr: string[]) {
  const parsed = hoursArr.map((h) => {
    const [day, ...rest] = h.split(':');
    return { day: day.trim(), time: rest.join(':').trim() };
  });

  parsed.sort((a, b) => DAY_ORDER.indexOf(a.day) - DAY_ORDER.indexOf(b.day));

  const groups = [];
  let i = 0;
  while (i < parsed.length) {
    let start = i;
    let end = i;
    while (
      end + 1 < parsed.length &&
      parsed[end + 1].time === parsed[start].time &&
      DAY_ORDER.indexOf(parsed[end + 1].day) === DAY_ORDER.indexOf(parsed[end].day) + 1
    ) {
      end++;
    }
    groups.push({ start: parsed[start].day, end: parsed[end].day, time: parsed[start].time });
    i = end + 1;
  }

  return groups;
}

interface HoursDisplayProps {
  hours: string[];
  expanded: boolean;
  onToggle: () => void;
}

export default function HoursDisplay({ hours, expanded, onToggle }: HoursDisplayProps) {
  return (
    <StyledTouchableOpacity onPress={onToggle} className="mb-4">
      <StyledView className="bg-gray-100 rounded-xl px-3 py-2 flex-row items-start">
        <Icon name="schedule" size={16} color={COLORS.mint} style={{ marginTop: 2 }} />
        <StyledView className="ml-2 flex-1">
          {expanded
            ? groupHours(hours).map((group, idx) => (
                <AppText key={idx} className="text-sm text-gray-800 mb-1">
                  <AppText className="font-bold">
                    {group.start === group.end
                      ? DAY_SHORT[group.start as keyof typeof DAY_SHORT]
                      : `${DAY_SHORT[group.start as keyof typeof DAY_SHORT]}–${
                          DAY_SHORT[group.end as keyof typeof DAY_SHORT]
                        }`}
                    :
                  </AppText>{' '}
                  {group.time}
                </AppText>
              ))
            : hours
                .filter((h) => h.startsWith(todayName))
                .map((h, idx) => {
                  const time = h.split(':').slice(1).join(':').trim();
                  return (
                    <AppText key={idx} className="text-sm text-gray-800">
                        <AppText className="font-bold">{DAY_SHORT[todayName as keyof typeof DAY_SHORT]}:</AppText> {time}
                    </AppText>
                  );
                })}
        </StyledView>
      </StyledView>
    </StyledTouchableOpacity>
  );
}
