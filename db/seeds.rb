puts "Saving user hernan"
u = User.find_by('hernan')
if u.present?
  puts "Already exists... resetting"
  u.destroy
end
u = User.new(username: 'hernan', password: 'PassTest123', full_name: 'Hernan Velasquez', failed_attempts: 0)
u.save
puts "Saved!"
