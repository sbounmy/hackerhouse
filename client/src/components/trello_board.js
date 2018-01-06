import React from 'react';

export default function(props) {
  const url = `https://trello.com/b/${props.id}.html`
  return (
    <div className="embed-responsive embed-responsive-1by1">
      <iframe className="embed-responsive-item" src={url} ></iframe>
    </div>
 );
}