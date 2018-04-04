import React, { Component } from 'react';
import Moment from 'react-moment';
import 'moment/locale/fr';
import FriendlyName from './friendly_name';
import _ from 'lodash';

export default class Message extends Component {
  constructor(props) {
    super(props);
    this.state = {
      truncate: true
    }
    this.toggleBody = this.toggleBody.bind(this);
  }

  toggleBody(e) {
    e.preventDefault();
    e.stopPropagation();
    this.setState({ truncate: !this.state.truncate });
  }

  bodyClassName() {
    return this.state.truncate ? 'text-truncate' : ''
  }

  render() {
    const { message } = this.props;
    const { user } = message;

    return(
      <li className={`border rounded my-3 px-3 py-2 ${this.props.hidden ? 'd-none' : ''}`} key={message.id}>
        <div className='d-flex flex-row justify-content-between align-items-start'>
          <h6 className="d-block mt-0 mb-1">
          <Moment locale="fr" format='DD/MM/YY'>
                {message.check_in}
          </Moment> - <Moment locale="fr" format='DD/MM/YY'>
                {message.check_out}
          </Moment> (<Moment ago to={message.check_out}>{message.check_in}</Moment>)
          </h6>
          <span>Reçu le <Moment format='DD/MM'>{message.created_at}</Moment></span>
        </div>
        <div className='d-flex flex-row justify-content-between'>
          <div className={this.bodyClassName()}>
            <strong><FriendlyName firstname={user.firstname} lastname={user.lastname} /></strong><i>, <a href={user.bio_url} target="_blank">{user.bio_title}</a></i>
            <p>
              <a href="#" onClick={this.toggleBody}>{message.body}</a>
            </p>
          </div>
          <div><img className="ml-2 rounded-circle" src={user.avatar_url} style={{'max-height': '20px'}}/></div>
        </div>
{/*        <div className='d-flex flex-row justify-content-end'>
          <button className='btn btn-outline-primary'>Call</button>
          <button className='btn btn-primary'>Email</button>
        </div>*/}
      </li>
    )
  }
}