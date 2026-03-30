import { serve } from "https://deno.land/std@0.131.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-client@2'

serve(async (req) => {
  // 1. Get the new notification record from the Webhook
  const { record } = await req.json()

  // 2. Setup Supabase Admin Client
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // 3. Fetch the FCM token for the user from the 'profiles' table
  const { data: userProfile } = await supabase
    .from('profiles')
    .select('fcm_token')
    .eq('id', record.user_id)
    .single()

  const fcmToken = userProfile?.fcm_token

  if (!fcmToken) {
    return new Response(JSON.stringify({ error: 'No token found' }), { status: 400 })
  }

  // 4. Send the notification to Firebase
  const firebaseResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `key=YOUR_FIREBASE_SERVER_KEY`, // Found in Firebase Project Settings
    },
    body: JSON.stringify({
      to: fcmToken,
      notification: {
        title: record.title,
        body: record.body,
      },
      priority: "high"
    }),
  })

  const result = await firebaseResponse.json()
  return new Response(JSON.stringify(result), { status: 200 })
})