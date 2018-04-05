import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchMessages } from '../actions';
import FriendlyName from './friendly_name';
import Message from './message';
import MessageTitle from './message_title';
import _ from 'lodash';

class MessagesPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showAll: false
    }
    this.toggleShowAll = this.toggleShowAll.bind(this);
  }

  componentDidMount() {
    this.props.fetchMessages(this.props.house_id);
  }

  toggleShowAll(e){
    e.preventDefault();
    e.stopPropagation();
    this.setState({
      showAll: !this.state.showAll
    })
  }

  toggleText() {
    return this.state.showAll ? 'Aucun autre message' : 'Voir tous les messages'
  }

  isHidden(index) {
    if (index > 2 && !this.state.showAll) {
      return true
    }
  }

  renderMessages() {
    return _.map(this.props.messages, (message, index) => {
      const { user } = message;
      return (
        <Message message={message}
                 created_at_prefix="Reçu le"
                 title={<MessageTitle message={message} />}
                 to={<div><strong><FriendlyName firstname={user.firstname} lastname={user.lastname} /></strong>
                    <i>, <a href={user.bio_url} target="_blank">{user.bio_title}</a></i></div>}
                 hidden={this.isHidden(index)}/>
      )
    });
  }

  render() {
    return (
       <div className="card mb-4 d-lg-block">
        <div className="card-body">
          <div className="d-flex flex-row justify-content-between align-items-start">
            <h6 className="mb-3">Mes messages</h6>
            <a className=""
               href="https://drive.google.com/drive/folders/1CLU7iON-CSUNud5i_b1nI1LBbnF83_gl?usp=sharing"
               target="_blank">Trouver un nouveau 🤙</a>
          </div>
          <ul className='list-unstyled'>
            {this.renderMessages()}
            <li>
              <p className="text-center">
                <a href="#" onClick={this.toggleShowAll}>{this.toggleText()}</a>
              </p>
            </li>
          </ul>
        </div>
      </div>
    )
  }
}

function mapStateToProps(state) {
  return { messages: state.houses.messages }
}

export default connect(mapStateToProps, { fetchMessages })(MessagesPanel);