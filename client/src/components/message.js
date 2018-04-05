import React, { Component } from 'react';
import Moment from 'react-moment';
import 'moment/locale/fr';
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
    return this.state.truncate ? 'clickable text-truncate' : 'clickable'
  }

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
          <div className={this.bodyClassName()}>
            {this.props.to}
            <p className={`my-2 px-2 py-1 bg-light border rounded ${this.bodyClassName()}`} onClick={this.toggleBody}>
              {message.body}
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