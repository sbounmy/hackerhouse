import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchMessages } from '../actions';
import Moment from 'react-moment';
import 'moment/locale/fr';
import FriendlyName from './friendly_name';
import _ from 'lodash';

class Message extends Component {
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

class MessagesPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showAll: false
    }
    this.toggleShowAll = this.toggleShowAll.bind(this);
  }

  componentDidMount() {
    if (this.props.user) {
      this.props.fetchMessages(this.props.user.house_id);
    }
  }

  badge(action) {
    if (action == 'check_out') {
      return <span className='badge badge-warning text-right'>Départ ✈️</span>
    } else {
      return <span className='badge badge-success text-right'>Arrivée ✅</span>
    }
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
      return (
        <Message message={message} hidden={this.isHidden(index)}/>
      )
    });
  }

  render() {
    const staying = (this.props.user && this.props.user.house_slug_id && this.props.user.check_out)

    if (staying) {
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
    } else {
      return ''
    }
  }
}

function mapStateToProps(state) {
  return { user: state.session.user, messages: state.houses.messages}
}

export default connect(mapStateToProps, { fetchMessages })(MessagesPanel);