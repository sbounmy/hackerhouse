import React from 'react';
import classNames from 'classnames';

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