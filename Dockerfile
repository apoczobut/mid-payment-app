FROM ruby:3.4.2-slim-bookworm


# GEM_HOME required for Ruby
ENV HOME /home/appuser
ENV GEM_HOME=/usr/local/bundle
RUN mkdir -p $GEM_HOME
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH
RUN apt-get update -qq && \
    apt-get -y --no-install-recommends install build-essential git libyaml-dev


# Update gems and bundler
RUN gem update --system --no-document

# Clean cache

# Install application gems
RUN groupadd -r appgroup && useradd -r appuser -g appgroup
RUN mkdir -p $HOME/app
WORKDIR $HOME/app


#COPY Gemfile* ./
COPY .ruby-version ./

RUN chown -R appuser:appgroup $HOME && \
    chown -R appuser:appgroup $GEM_HOME

USER appuser

#RUN bundle install

# Copy application files
COPY . .

RUN rm -rf $HOME/bundle/cache/*
RUN rm -rf $HOME/app/tmp/cache
