import React, { Component } from 'react';
import Moment from 'react-moment';
import 'moment/locale/fr';
import UserAvatars from './user_avatars';
import Avatar from './avatar';
import _ from 'lodash';
import Text from './text';

export default class Message extends Component {
  render() {
    const { message } = this.props;
    const { user } = message;

    return(
      <li className={`border rounded my-3 px-3 py-2 ${this.props.hidden ? 'd-none' : ''}`} key={message.id}>
        <div className='d-flex flex-row justify-content-between align-items-start'>
          <h6 className="d-block mt-0 mb-1">
            {this.props.title}
          </h6>
          <span>{this.props.created_at_prefix} <Moment format='DD/MM'>{message.created_at}</Moment></span>
        </div>
        <div className='d-flex flex-row justify-content-between'>
          <div style={{'min-width': 0}}>
            {this.props.to}
            <Text className="my-2 py-1">
              {message.body}
            </Text>
          </div>
          <div><Avatar className='ml-2' user={user} xs circle/></div>
        </div>
        <div>
          <button type="button" class="d-inline btn btn-outline-secondary btn-sm">👍 {message.like_ids.length}</button><UserAvatars ids={message.like_ids} />
        </div>
{/*        <div className='d-flex flex-row justify-content-end'>
          <button className='btn btn-outline-primary'>Call</button>
          <button className='btn btn-primary'>Email</button>
        </div>*/}
      </li>
    )
  }
}