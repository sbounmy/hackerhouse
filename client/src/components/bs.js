import React from 'react';
import classNames from 'classnames';
import { IntercomAPI } from 'react-intercom';

export const Col = props => {
  const className = classNames(props.xs && `col-xs-${props.xs}`,
                               props.sm && `col-sm-${props.sm}`,
                               props.md && `col-md-${props.md}`,
                               props.lg && `col-lg-${props.lg}`);
  return (
    <div className={className}>
      {props.children}
    </div>
  )
}

export const Row = props => {
  return (
    <div className="row">
      {props.children}
    </div>
  )
}

export const Card = props => {
  const className = classNames('card', props.className)
  return (
    <div className={className}>
      <div className="card-body">
        <h6 className="mb-3">{props.title}</h6>
        {props.children}
      </div>
    </div>
  )
}

export const Button = props => {
  const className = classNames('btn',
                                props.type && `btn-${props.type}`)
  let onClick = (props.message && (() => { IntercomAPI('showNewMessage', props.message)}))
                || props.onClick
  return (
    <button type='button' className={className} onClick={onClick}>
      {props.children}
    </button>
  )
}