import React, { Component } from 'react';
import { Card } from './bs'

const renderLink = (icon, name, url) => {
  const className = `text-muted icon icon-${icon} mr-3`;

  return (
    <li>
      <span className={className}></span>
      <a href={url} target="_blank">{name}</a>
    </li>
  );
}

export default props => {
  return (
    <Card title="Liens important"
          className="d-md-block d-lg-block mb-4">
      <ul className="list-unstyled list-spaced">
        {renderLink('smashing', 'Slack', 'https://hackerhouseparis.slack.com')}
        {renderLink('mixi', 'Meetup', 'https://www.meetup.com/HackerHouse-Paris')}
        {renderLink('instagram-with-circle', 'Instagram', 'https://www.instagram.com/hackerhouseparis/')}
        {renderLink('github', 'Github', 'https://github.com/hackerhouseparis')}
        {renderLink('youtube', 'Youtube', 'https://www.youtube.com/channel/UCGNRggfCwXF5pYyr74qY3eg')}
      </ul>
    </Card>
  );
}