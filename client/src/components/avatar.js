import React from 'react';
import classNames from 'classnames';

export default props => {
  if (!props.user) return ''
  const className = classNames(props.className,
                               props.xs && 'xs',
                               props.sm && 'sm',
                               props.lg && 'lg',
                               props.xl && 'xl',
                               props.circle && 'rounded-circle',
                               props.rounded && 'rounded');
  const { user } = props;

  return (
    <img title={user.firstname}
         className={className}
         src={user.avatar_url}
         />
  )
}