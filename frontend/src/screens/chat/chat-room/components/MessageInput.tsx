import React from 'react';
import { View, TextInput, TouchableOpacity, ActivityIndicator } from 'react-native';
import { styled } from 'nativewind';
import { MaterialIcons as Icon } from '@expo/vector-icons';
import { COLORS, SHADOWS } from '../../../../theme/colors';

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
  return (
    <StyledView 
      className="flex-row items-end px-4 py-3 bg-white"
      style={{
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -2 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
        elevation: 10,
        borderTopColor: 'rgba(31,201,195,0.12)',
        borderTopWidth: 1,
      }}
    >
      <StyledTextInput
        className="flex-1 bg-gray-100 rounded-2xl px-4 py-3 text-base text-gray-900 mr-3"
        placeholder="Type a message..."
        placeholderTextColor="#9CA3AF"
        value={input}
        onChangeText={setInput}
        editable={!sending}
        onSubmitEditing={onSend}
        returnKeyType="send"
        multiline
        maxLength={1000}
        style={{
          minHeight: 44,
          maxHeight: 100,
        }}
      />
      
      <StyledTouchableOpacity
        onPress={onSend}
        className="w-12 h-12 rounded-2xl items-center justify-center"
        disabled={sending || !input.trim()}
        style={{
          backgroundColor: sending || !input.trim() ? '#D1D5DB' : COLORS.mint,
          ...SHADOWS.button,
          opacity: sending || !input.trim() ? 0.5 : 1,
        }}
      >
        {sending ? (
          <ActivityIndicator size="small" color="white" />
        ) : (
          <Icon name="send" size={20} color="white" />
        )}
      </StyledTouchableOpacity>
    </StyledView>
  );
} 