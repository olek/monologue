# Monologue::UserRecord.create!({name: "Monologue", email: "monologue@example.com", password: "monologue", password_confirmation: "monologue"})

# password logic is in rails plugin ecosystem, makes for convoluted new user creation
s = ORMivore::Session.new(Monologue::Repos, Monologue::Associations)
u = Monologue::User::ViewAdapter.new(s.repo.user.create(name: "Monologue", email:"monologue@example.com"))
u.assign_attributes(password: "monologue", password_confirmation: 'monologue')
u.save or fail u.errors.full_messages.inspect
