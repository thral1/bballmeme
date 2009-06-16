# BballMeme / FballMeme - Sports News Aggregator

> **Note**: This project was actively developed from 2009-2012 and represents a historical snapshot of a sports news aggregation platform.

A Ruby on Rails web application that aggregates, analyzes, and ranks sports news articles from multiple RSS feeds and online sources. The platform operated two separate sites:
- **BBallnews.com** - NBA and basketball news aggregation
- **FBallnews.com** - NFL and American football news aggregation

## Overview

This application crawls RSS feeds from major sports news outlets, extracts article content, analyzes engagement metrics (comments, backlinks, site traffic), and presents a ranked feed of the most relevant and engaging articles. Articles are organized by team and include intelligent content extraction and duplicate detection.

## Key Features

### Content Aggregation
- **RSS Feed Crawling**: Automated feed discovery and article extraction
- **Smart Content Parsing**: Uses readability algorithms to extract main article content from HTML
- **Metadata Extraction**: Automatically parses titles, authors, publication dates, and article text
- **Team & Player Detection**: Regex-based entity recognition for all 30 NBA teams and 32 NFL teams

### Engagement Analytics
- **Multi-Platform Comment Counting**: Tracks comments across 20+ platforms including:
  - ESPN Conversation API
  - WordPress, Blogger, TypePad, Disqus
  - CBS Sports, Fox Sports, NY Daily News, and more
- **Backlink Analysis**: Tracks how many other articles link to each piece
- **Traffic Metrics**: Integrates with Compete.com API for site visitor statistics

### Intelligent Ranking
- **Composite Scoring Algorithm** with weighted factors:
  - Comments (40% weight)
  - Backward links (40% weight)
  - Visitors per month (10% weight)
  - Publication bias (5% weight) - e.g., ESPN articles ranked higher
  - Author bias (5% weight)
- **Statistical Normalization**: Uses z-scores for fair comparison across different scales
- **Automatic Rescoring**: Background jobs update rankings every 5 minutes

### Multi-Sport Architecture
- **Hostname-Based Routing**: Separate domains route to sport-specific content
- **Single Table Inheritance**: Shared article base class with sport-specific extensions
- **Team-Specific Views**: Browse news filtered by your favorite team

## Technical Stack

### Framework & Language
- **Ruby on Rails 2.3.4** - MVC web framework
- **Ruby** - Server-side programming language
- **MySQL** - Primary database (versions 4.1-5.0)

### Key Dependencies
- **Nokogiri** - HTML/XML parsing for content extraction
- **Rufus Scheduler** - Background job scheduling
- **BackgroundRb** - Background worker processing
- **will_paginate** - Article pagination
- **ActiveRecord** - ORM for database operations

### External APIs
- **Compete.com API** - Website traffic and ranking metrics
- **ESPN Conversation API** - Comment counts for ESPN articles
- Platform-specific comment APIs (CBS, Fox Sports, etc.)

## Architecture

```
┌─────────────────────────────────────────────┐
│   Background Processing (Task Scheduler)    │
├─────────────────────────────────────────────┤
│  Every 5m:   Rescore articles (Ranker)      │
│  Every 1m:   Process FIFO queue (Workers)   │
│  Every 30m:  Clear cache                    │
└─────────────────┬───────────────────────────┘
                  │
         ┌────────▼────────┐
         │  Perl Scripts   │
         │  (Feed Crawler) │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │ Rails Web App   │
         │ - Content Parse │
         │ - Engagement    │
         │ - Ranking       │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │ MySQL Database  │
         │ - Articles      │
         │ - Teams         │
         │ - Feeds         │
         └─────────────────┘
```

## Project Structure

```
bballmeme/
├── app/
│   ├── controllers/      # HTTP request handlers
│   │   ├── bb_articles_controller.rb
│   │   ├── fb_articles_controller.rb
│   │   ├── bb_teams_controller.rb
│   │   └── fb_teams_controller.rb
│   ├── models/          # Business logic and data models
│   │   ├── article.rb           # Base article with parsing logic
│   │   ├── bb_article.rb        # Basketball-specific article
│   │   ├── fb_article.rb        # Football-specific article
│   │   ├── ranker.rb            # Scoring algorithm
│   │   ├── feed.rb              # RSS feed management
│   │   └── team.rb              # Team data
│   └── views/           # HTML templates
├── config/
│   ├── database.yml     # Database configuration
│   ├── routes.rb        # URL routing (hostname-based)
│   └── environment.rb   # Rails configuration
├── db/
│   ├── migrate/         # Database migrations
│   └── schema.rb        # Database schema
├── lib/
│   └── workers/         # Background job workers
├── perl/                # Feed crawling scripts
├── public/              # Static assets (CSS, JS, images)
├── task_scheduler.rb    # Scheduled background tasks
└── test/                # Unit and functional tests
```

## Database Schema

### Core Tables
- **articles** - Article content, metadata, and engagement metrics
  - Single Table Inheritance (type: BBArticle or FBArticle)
  - Fields: url, title, author, publication_date, text, num_comments, num_backward_links, score, zscore, teams_mentioned, players_mentioned
- **teams** - NBA and NFL team definitions (city, name, type)
- **feeds** - RSS feed sources (url, name, sport, active, relevance)
- **links** - Extracted hyperlinks from articles (many-to-many with articles)
- **urlinfos** - Cached website metrics (visitors, ranking)
- **feedbacks** - User-submitted feedback

## Setup Instructions

### Prerequisites
- Ruby 1.8.7+ (compatible with Rails 2.3.4)
- MySQL 4.1-5.0
- Perl (for feed crawling scripts)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bballmeme
   ```

2. **Install dependencies**
   ```bash
   gem install rails -v 2.3.4
   gem install mysql
   gem install nokogiri
   gem install rufus-scheduler
   gem install will_paginate
   ```

3. **Configure database**
   ```bash
   # Edit config/database.yml with your MySQL credentials
   # Create databases
   rake db:create
   rake db:migrate
   ```

4. **Seed initial data**
   ```bash
   # Load team data and RSS feeds
   rake db:seed
   ```

5. **Start the server**
   ```bash
   ruby script/server
   ```

6. **Start background processing**
   ```bash
   # In a separate terminal
   rake backgroundrb:start

   # Start task scheduler
   ruby task_scheduler.rb
   ```

### Configuration

- **Database**: Edit [config/database.yml](config/database.yml)
- **Routes**: Hostname-based routing in [config/routes.rb](config/routes.rb)
- **Feed Sources**: Manage via Feeds CRUD interface at `/feeds`
- **Background Jobs**: Configure in [config/backgroundrb.yml](config/backgroundrb.yml)

## Data Flow

1. **Acquisition**: Perl scripts crawl RSS feeds → Write to FIFO queue
2. **Processing**: Background worker reads queue every minute → Creates Article records
3. **Analysis**: Article model parses HTML, counts comments, fetches site metrics
4. **Scoring**: Ranker calculates composite scores every 5 minutes
5. **Display**: Controllers present ranked articles to users

## Key Algorithms

### Content Extraction (Readability Algorithm)
The [article.rb:42-156](app/models/article.rb#L42-L156) implements a sophisticated content extraction algorithm:
- Parses HTML and builds DOM tree
- Scores paragraphs based on content density
- Removes boilerplate (ads, navigation, sidebars)
- Extracts clean article text

### Comment Counting
Multi-platform comment detection in [article.rb:204-389](app/models/article.rb#L204-L389):
- ESPN Conversation API
- WordPress comment count in `<dd class="comment-count">`
- Blogger via `showNumComments()`
- TypePad, Disqus, IntenseDebate
- Site-specific parsers (CBS, Fox Sports, ProFootballTalk, etc.)

### Ranking Algorithm
The [ranker.rb](app/models/ranker.rb) implements weighted composite scoring:
```ruby
score = (0.40 × normalized_comments) +
        (0.40 × normalized_backlinks) +
        (0.10 × normalized_visitors) +
        (0.05 × publication_bias) +
        (0.05 × author_bias)
```

## Testing

```bash
# Run all tests
rake test

# Run specific test suites
rake test:units
rake test:functionals
```

Test fixtures available in [test/fixtures/](test/fixtures/).

## Historical Context

This project was developed during the early days of content aggregation platforms (2009-2012), before modern social media dominance and sophisticated content recommendation systems. It represents an early approach to:
- Automated sports news curation
- Multi-source engagement metric aggregation
- Algorithm-based content ranking
- RSS feed as primary content distribution

### Technology Choices (for historical context)
- **Rails 2.3.4**: State-of-the-art Ruby framework at the time
- **Perl scripts**: Common for web scraping tasks in 2009
- **Compete.com API**: Popular web analytics service (now defunct)
- **RSS feeds**: Primary content distribution before social media APIs

## Limitations & Known Issues

- Rails 2.3.4 is outdated and has known security vulnerabilities
- Some external APIs (Compete.com) are no longer operational
- Designed for specific sports sites; many feed URLs may be outdated
- No mobile-responsive design (predates responsive web design trends)
- Comment counting APIs may have changed or been deprecated

## Future Improvements (if modernizing)

- Upgrade to Rails 7.x with modern Ruby
- Replace Perl scripts with Ruby-based feed processing
- Implement responsive design for mobile devices
- Add social media integration (Twitter, Reddit engagement metrics)
- Use modern background job framework (Sidekiq)
- Implement full-text search (Elasticsearch)
- Add real-time updates via WebSockets
- Machine learning for better article relevance

## License

MIT License - See [LICENSE](LICENSE) file for details

## Contributing

This is a historical project and is not actively maintained. However, it may serve as:
- Educational reference for Rails 2.x applications
- Example of content aggregation architecture
- Study of engagement metric collection
- Basis for a modernized sports news platform

## Contact

For questions about this codebase, please open an issue on GitHub.

---

**Project Timeline**: June 2009 - September 2012
**Primary Development**: June 2009 - November 2010
**Published to GitHub**: November 2025
**Ruby Version**: 1.8.7
**Rails Version**: 2.3.4
