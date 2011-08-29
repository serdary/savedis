User.all.each do |u|
  u.bookmarks.delete_all
  u.notes.delete_all
end

Bookmark.all.each do |b|
  b.tags.delete_all
end
Note.all.each do |n|
  n.tags.delete_all
end

Tag.delete_all
User.delete_all
Bookmark.delete_all
Note.delete_all
Favorite.delete_all

ActiveRecord::Base.connection.execute('ALTER TABLE users AUTO_INCREMENT = 1')
ActiveRecord::Base.connection.execute('ALTER TABLE bookmarks AUTO_INCREMENT = 1')
ActiveRecord::Base.connection.execute('ALTER TABLE notes AUTO_INCREMENT = 1')
ActiveRecord::Base.connection.execute('ALTER TABLE tags AUTO_INCREMENT = 1')
ActiveRecord::Base.connection.execute('ALTER TABLE favorites AUTO_INCREMENT = 1')

# Add users
user1 = User.create(:username => 'savedis_admin',
  :email => 'admin@savedis.com',
  :hashed_password => '0a183b039f9ab9e7122efc1d2de697f76b77a1e66d57f588bc860c881b6cb4a4',
  :salt => '0.7610993305810122 2011-08-05 16:28:19 +0300')
  
user2 = User.create(:username => 'serdar',
  :email => 'serdar@savedis.com',
  :hashed_password => '0a183b039f9ab9e7122efc1d2de697f76b77a1e66d57f588bc860c881b6cb4a4',
  :salt => '0.7610993305810122 2011-08-05 16:28:19 +0300')

# Add Bookmarks
for i in (1..10) do
  user1.bookmarks << Bookmark.create(:title => "Bookmark #{i} -u1",
    :url =>   "http://#{i}-url.com",
    :description => 
      %{Bookmark #{i} - user 1 Loooooooooong Description (Not so long, huh!) },
    :created_by => user1.id)
  
  user1.bookmarks[i-1].tags << Tag.create(:value => "user1 tag #{i}", :slug => "user1-tag-#{i}")
    
  user2.bookmarks << Bookmark.create(:title => "Bookmark #{i} -u2",
    :url =>   "http://#{i}-url-u2.com",
    :description => 
      %{Bookmark #{i} - user 2 Loooooooooong Description (Not so long, huh!) },
    :created_by => user2.id)
      
  user2.bookmarks[i-1].tags << Tag.create(:value => "user2 tag #{i}", :slug => "user2-tag-#{i}")
  
  bookmark_user1 = user1.bookmark_users.find_by_bookmark_id(user1.bookmarks[i-1].id)
  bookmark_user2 = user2.bookmark_users.find_by_bookmark_id(user2.bookmarks[i-1].id)
  bookmark_user1.update_attributes(:title => user1.bookmarks[i-1].title + ' changed!',
    :description => user1.bookmarks[i-1].description + ' changed!')
  bookmark_user2.update_attributes(  :title => user2.bookmarks[i-1].title + ' changed!',
    :description => user2.bookmarks[i-1].description + ' changed!')
    
  #make some private and deleted bookmarks
  if i < 3
    bookmark_user1.update_attributes(:is_deleted => 1)
    bookmark_user2.update_attributes(:is_deleted => 1)
    
    user1.bookmarks[i-1].update_attributes(:save_count => 0)
    user2.bookmarks[i-1].update_attributes(:save_count => 0)
  elsif i < 6
    bookmark_user1.update_attributes(:is_private => 1)
    bookmark_user2.update_attributes(:is_private => 1)
  end
  
  user1.update_counters('bookmark')
  user2.update_counters('bookmark')
  user1.update_counters('note')
  user2.update_counters('note')
end

# Add Notes
for i in (1..10) do
  user1.notes << Note.create(:title => "My Note #{i} -u1",
    :content => "My Note content #{i} -u1",
    :is_deleted => i < 3,
    :is_private => i < 4)

  user2.notes << Note.create(:title => "My Note #{i} -u2",
    :content => "My Note content #{i} -u2",
    :is_deleted => i < 3,
    :is_private => i < 4)
end