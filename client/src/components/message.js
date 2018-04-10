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
    const isLikeByUser = _.includes(message.like_ids, user.id);

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
          <Button type='outline-secondary'
                  className="d-inline"
                  action={isLikeByUser ?
                    this.props.unlikeMessage :
                    this.props.likeMessage
                  }
                  actionProps={{id: message.id, user_id: user.id}}
                  active={isLikeByUser}
                  sm>👍 {message.like_ids.length}</Button>
          <UserAvatars ids={message.like_ids} />
        </div>
{/*        <div className='d-flex flex-row justify-content-end'>
          <button className='btn btn-outline-primary'>Call</button>
          <button className='btn btn-primary'>Email</button>
        </div>*/}
      </li>
    )
  }
}

const mapStateToProps = (state) => {
  return { user: state.session.user }
}
export default connect(mapStateToProps, { likeMessage, unlikeMessage })(Message);