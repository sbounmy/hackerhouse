import React, { Component } from 'react';
import { connect } from 'react-redux';
import { IntercomAPI } from 'react-intercom';

import _ from 'lodash';

class LinksPanel extends Component {
  renderLink(icon, name, url) {
    const className = `text-muted icon icon-${icon} mr-3`;

    return (
      <li>
        <span className={className}></span>
        <a href={url} target="_blank">{name}</a>
      </li>
    );
  }

  render() {
    return (
      <div className="card d-md-block d-lg-block mb-4">
        <div className="card-body">
          <h6 className="mb-3">Liens important</h6>
          <ul className="list-unstyled list-spaced">
            {this.renderLink('smashing', 'Slack', 'https://hackerhouseparis.slack.com')}
            {this.renderLink('mixi', 'Meetup', 'https://www.meetup.com/HackerHouse-Paris')}
            {this.renderLink('instagram-with-circle', 'Instagram', 'https://www.instagram.com/hackerhouseparis/')}
            {this.renderLink('github', 'Github', 'https://github.com/hackerhouseparis')}
            {this.renderLink('youtube', 'Youtube', 'https://www.youtube.com/channel/UCGNRggfCwXF5pYyr74qY3eg')}
          </ul>
        </div>
      </div>
    );
  }
}

export default connect(null, { })(LinksPanel);