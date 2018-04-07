import React from 'react';
import Moment from 'react-moment';

export default function MessageTitle(props) {
  const { message } = props;

  return (
    <div>
      <Moment locale="fr" format='DD MMMM YYYY'>{message.check_in}</Moment> - <Moment locale="fr" format='DD MMMM YYYY'>
            {message.check_out}
      </Moment> (<Moment ago to={message.check_out}>{message.check_in}</Moment>)
    </div>
  )
}
