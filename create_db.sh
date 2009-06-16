#!/bin/bash
rake db:schema:load
rake db:fixtures:load
