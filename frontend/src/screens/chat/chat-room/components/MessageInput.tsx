import React from 'react';
import { View, TextInput, TouchableOpacity, ActivityIndicator } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { COLORS } from '../../../../theme/colors';

const StyledView = styled(View);
const StyledTextInput = styled(TextInput);
const StyledTouchableOpacity = styled(TouchableOpacity);

interface MessageInputProps {
  input: string;
  setInput: (text: string) => void;
  sending: boolean;
  onSend: () => void;
}

export default function MessageInput({ 
  input, 
  setInput, 
  sending, 
  onSend 
}: MessageInputProps) {
  const insets = useSafeAreaInsets();

  return (
    <StyledView 
      className="flex-row items-center px-4 py-3 bg-white shadow-sm border-t border-gray-100 absolute bottom-0 left-0 right-0"
      style={{
        paddingBottom: insets.bottom,
      }}
    >
      <StyledTouchableOpacity
        className="w-8 h-8 items-center justify-center mr-3"
      >
        <Icon name="attach-file" size={20} color="#6B7280" />
      </StyledTouchableOpacity>
      
      <StyledView 
        className="flex-row items-center flex-1 mr-3 bg-gray-50 rounded-2xl px-4 py-2.5 min-h-[40px]"
      >
        <StyledTextInput
          className="flex-1 text-base text-gray-900 min-h-[20px] max-h-[80px] py-0"
          placeholder="Message"
          placeholderTextColor="#9CA3AF"
          value={input}
          onChangeText={setInput}
          editable={!sending}
          onSubmitEditing={onSend}
          returnKeyType="send"
          multiline
          maxLength={1000}
        />
      </StyledView>
      
      <StyledTouchableOpacity
        className="w-8 h-8 items-center justify-center mr-2"
      >
        <Icon name="mic" size={20} color="#6B7280" />
      </StyledTouchableOpacity>
      
      <StyledTouchableOpacity
        onPress={onSend}
        className={`w-8 h-8 items-center justify-center ${
          sending || !input.trim() ? 'opacity-50' : 'opacity-100'
        }`}
        disabled={sending || !input.trim()}
      >
        {sending ? (
          <ActivityIndicator size="small" color={COLORS.mint} />
        ) : (
          <Icon name="send" size={20} color={input.trim() ? COLORS.mint : "#6B7280"} />
        )}
      </StyledTouchableOpacity>
    </StyledView>
  );
} 