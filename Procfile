web: bundle exec puma -C config/puma.rb
release: export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.apt/usr/lib/x86_64-linux-gnu/blas && rake db:migrate