#!/bin/bash
#rake db:drop
rake db:schema:load
rake db:fixtures:load
#rake test:units
rake test:functionals
rake test:integration


