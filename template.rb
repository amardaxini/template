require 'rubygems'
require 'ruby-debug'

run "rm -fr public/index.html"
run "rm public/favicon.ico"
run "rm -rf public/javascripts/*.js"
run "touch public/javascripts/application.js"
FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__),"public","javascripts"))+"/.","public/javascripts/")
FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__),"public","stylesheets"))+"/.","public/stylesheets/")
FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__),"public","images"))+"/.","public/images/")
FileUtils.cp_r(File.expand_path(File.join(File.dirname(__FILE__),"public","application_helper.rb")),"app/helpers/application_helper.rb")
gem "devise"
#Rails.root.basename.to_s
generate("devise:install")
model_name = ask("What is your model name for authentcation?")
generate("devise #{model_name}")
generate("devise:views #{model_name.pluralize}")
generate("controller #{model_name.pluralize}")
generate("controller home index")
#app_name = ask("What is your application name?")
app_name = File.expand_path(".").split("/").last
file "config/routes.rb", <<-END
#{app_name.camelize}::Application.routes.draw do
  devise_for :#{model_name.pluralize}
  root :to => "home#index"
end
END
file "app/views/layouts/application.html.erb", <<-END
<!DOCTYPE html>
<html>
<head>
  <%= stylesheet_link_tag 'reset','grid','application'%>
  <%= javascript_include_tag :all %>
  <title>#{app_name.camelize}  <%= h(yield(:title) || "Untitled") %></title>
  <%= csrf_meta_tag %>
</head>
<body>
<div class="container_16 every-thing">
  <div id="fb-root"></div>
  <div class="header">
    <div class="login-wrapper grid_16">
      <div class="login-bar-left grid_8">#{app_name.camelize}</div>
      <div class="grid_3" id="login-bar">
        <ul>
          <% if !current_user.blank? %>
              <li><%=link_to "Profile | ", edit_#{model_name}_registration_path %> </li>
              <li><%= link_to "Logout",  destroy_#{model_name}_session_path%></li>
          <% else %>
              <li><%= link_to "Login | ", new_#{model_name}_session_path %></li>
              <li><%= link_to "Register ", new_#{model_name}_registration_path %></li>
          <% end %>
        </ul>
      </div>
    </div>
    <%= clearing_span %>
    <div class="main-nav">
      <ul>
        <% if current_#{model_name}.blank? %>
            <li><%= link_to "Login", new_#{model_name}_session_path %></li>
            <li><%= link_to "Register ", new_#{model_name}_registration_path %></li>
        <% else %>
            <li><%= link_to "Home", root_url, :method => :delete %></li>
            <li><%= link_to "#{model_name.camelize}",#{model_name}_path %></li>
        <% end %>

      </ul>
    </div>
  </div>
  <%= clearing_span %>
  <div id="wrapper">
    <div id="content" class="<%= main_content_css_class %>">
      <%= yield %>
    </div>
    <div class="<%=  sidebar_css_class %>">
      <%=yield :sidebar %>
    </div>

    <%= clearing_span %>
    <div class="push"></div>

    <%= clearing_span %>
  </div>

  <%= clearing_span %>
</div>
<%= clearing_span %>
<div  class="container_16">
  <div id="footer">
    <p class="copytight">&copy; 2010 <a href="http://raistech.com">Amar Daxini</a></p>
    <%= yield :javascripts %>

  </div>
</div>
</body>
</html>
END
file "config/initializers/setup_mail.rb", <<-END 
#ActionMailer::Base.smtp_settings = {
#  :address              => "smtp.gmail.com",
#  :port                 => 587,
#  :domain               => "",
#  :user_name            => "",
#  :password             => "",
#  :authentication       => "plain",
#  :enable_starttls_auto => true
#}
ActionMailer::Base.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => 587,
  :domain => "",
  :authentication => :plain,
  :user_name => "",
  :password => "",
  :enable_starttls_auto => true

}
ActionMailer::Base.default_url_options[:host] = "iitb.heroku.com"
END

