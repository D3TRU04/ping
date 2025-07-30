import { supabase } from '../../lib/supabase';

export async function uploadProfilePicture(userId: string, file: Blob, extension: string = 'jpg') {
  const fileName = `${userId}.${extension}`;
  const filePath = `profile-pictures/${fileName}`;

  try {
    const { data, error } = await supabase.storage
      .from('profile-pictures')
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: true,
        contentType: file.type || 'image/jpeg',
      });

    if (error) {
      return null;
    }

    const publicUrl = supabase.storage.from('profile-pictures').getPublicUrl(filePath);
    return publicUrl.data.publicUrl;
  } catch (error) {
    // Handle error silently
    return null;
  }
}
