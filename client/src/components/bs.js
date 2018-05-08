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
    <div className={className} style={props.style}>
      {props.header &&
        <div class="card-header">
          {props.header}
        </div>
      }
      <div className="card-body">
        <div className="d-flex flex-row justify-content-between align-items-start">
          <h6 className="mb-3">{props.title}</h6>
          {props.action}
        </div>
        {props.children}
      </div>
      {props.footer &&
        <div class="card-footer">
          {props.footer}
        </div>
      }
    </div>
  )
}

export const Button = props => {
  const className = classNames('btn',
                                props.active && 'active',
                                props.type && `btn-${props.type}`,
                                props.xs && `btn-xs`,
                                props.sm && `btn-sm`,
                                props.md && `btn-md`,
                                props.lg && `btn-lg`)
  const onClick = (event) => {
    (props.message && IntercomAPI('showNewMessage', props.message))
    || (props.action && props.action(props.actionProps))
    || (props.onClick && props.onClick(event))
  }

  return (
    <button type='button' className={className} onClick={onClick} disabled={props.disabled}>
      {props.children}
    </button>
  )
}