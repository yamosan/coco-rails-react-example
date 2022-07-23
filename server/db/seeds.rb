# user1@example.com
u1 = User.create!(
  name: 'user1',
  age: 20,
  firebase_uid: '1SnkCHDQmHeRl7vbDvRWC1U6HQ33'
)
Post.create!(
  title: 'post1',
  content: '',
  user_id: u1.id
)

# user2@example.com
u2 = User.create!(
  name: 'user2',
  age: 20,
  firebase_uid: 'KmEeZk0dYPQvbOWRPxh22FmjypR2'
)
Post.create!(
  title: 'post2',
  content: '',
  user_id: u2.id
)
