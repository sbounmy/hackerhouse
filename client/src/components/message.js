import React, { Component } from 'react'
import Moment from 'react-moment'
import 'moment/locale/fr'
import UserAvatars from './user_avatars'
import Avatar from './avatar'
import _ from 'lodash'
import Text from './text'
import { Button } from './bs'
import { connect } from 'react-redux'
import { likeMessage, unlikeMessage } from '../actions'
import Action from '../actions'

class Message extends Component {
  render() {
    const { message, user } = this.props;
    const author = message.user;
    const isLikeByUser = _.includes(message.like_ids, user.id);

    return(
      <li className={`border rounded my-3 px-3 py-2 ${this.props.hidden ? 'd-none' : ''}`} key={message.id}>
        <div className='d-flex flex-row align-items-start'>
          <Avatar className='mx-2' user={author} sm circle/>
          <div style={{'min-width': '0px'}} className='col-2'>
            {this.props.to}
            <Moment format='DD/MM'>{message.created_at}</Moment>
          </div>
          <div style={{'min-width': 0}}>
            <Text className="mb-1">
              {message.body}
            </Text>
            <p>
              <i>{this.props.title}</i>
            </p>
            <div>
              <Button type='outline-secondary'
                  className="d-inline"
                  action={this.props.likeMessage}
                  actionProps={{id: message.id, user_id: user.id}}
                  active={isLikeByUser}
                  disabled={isLikeByUser}
                  sm>👍 {message.like_ids.length}</Button>
              <UserAvatars ids={message.like_ids} />
            </div>
          </div>
        </div>
      </li>
    )
  }
}

const mapStateToProps = (state) => {
  return { user: state.session.user }
}
export default connect(mapStateToProps, { likeMessage })(Message);