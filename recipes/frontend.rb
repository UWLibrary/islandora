#
# Cookbook Name:: islandora
# Recipe:: frontend
#
# Copyright 2013, University of Toronto Libraries, Ryerson University Library and Archives
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install packaged libraries on the system
if platform?("ubuntu")
  node[:islandora][:libraries].each do |library|
    package library
  end
end

# Install Drupal, including specified modules
include_recipe 'drupal::install'

include_recipe 'git'

# Checkout tuque git repository as library
directory "#{node[:drupal][:dir]}/sites/all/libraries/tuque" do
  action :create
  recursive true
  user node['drupal']['system']['user']
  group node['drupal']['system']['group']
end

git "#{node[:drupal][:dir]}/sites/all/libraries/tuque" do
  repository "git://github.com/Islandora/tuque.git"
  action :checkout
  user node['drupal']['system']['user']
  group node['drupal']['system']['group']
end

# Install Islandora modules
node[:islandora][:repos].each do |repo|
  
  # Checkout git repositories as Drupal modules
  git "#{node[:drupal][:dir]}/sites/all/modules/#{repo}" do
    repository "git://github.com/Islandora/#{repo}.git"
    action :checkout
    user node['drupal']['system']['user']
    group node['drupal']['system']['group']
  end

  # strip "solution pack" out of the repo name for the module
  mod = repo.sub('solution_pack_','')

  # Use Drush to install downloaded modules
  drupal_module mod do
    dir node['drupal']['dir']
    action :install
  end
end

# Install remaining modules
# FIXME: this should be moved to an attribute
%w(xml_forms xml_form_builder islandora_solr_config xml_schema_api xml_form_elements xml_form_api zip_importer islandora_basic_image islandora_basic_collection).each do |mod|
  drupal_module mod do
    dir node['drupal']['dir']
    action :install
  end
end