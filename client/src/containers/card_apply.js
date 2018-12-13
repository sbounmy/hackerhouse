import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Card, Button } from '../components/bs';
import { fetchMessages } from '../actions';
import { ReactTypeformEmbed } from 'react-typeform-embed';
import Moment from 'react-moment';
import { IntercomAPI } from 'react-intercom';
import qs from 'query-string';
import 'moment/locale/fr';
import _ from 'lodash';

class CardApply extends Component {
  constructor(props) {
    super(props);
    this.openForm = this.openForm.bind(this);
  }

  componentDidMount = async () => {
    if (this.props.user) {
      const res = await this.props.fetchMessages({'q[user_id]': this.props.user.id});
      if (_.isEmpty(res)) this.openForm()
    }
  }

  openForm() {
    this.typeformEmbed.typeform.open();
  }

  applyParams() {
    const { user } = this.props
    let params = {
      firstname: user.firstname,
      lastname: user.lastname,
      email: user.email,
      user_id: user.id
    }

    // https://www.typeform.com/help/sandbox/
    if (process.env.NODE_ENV != 'production') {
      params['__dangerous-disable-submissions'] = 1
      params.firstname = `${params.firstname}-SANDBOX_TYPEFORM` // need a visual way to know it is sandbox
    }
    return qs.stringify(params)
  }

  intercomUpdate = () => {
    const { user } = this.props
    IntercomAPI('update', {applied: true})
  }

  render() {
    const { user } = this.props;

    return (
      <Card className='mb-4 d-lg-block'
            title="Séjour 🖥 + 😴">
        <div className='apply-popup'>
          <ReactTypeformEmbed
            url={`https://hackerhouseparis.typeform.com/to/qmztfk?${this.applyParams()}`}
            hideHeader={true}
            popup={true}
            mode="drawer_left"
            ref={(tf => this.typeformEmbed = tf)}
            onSubmit={this.intercomUpdate}/>
        </div>
        <p>Viens vivre avec nous !</p>
        <Button type='primary'
                onClick={this.openForm}>
                  Postuler maintenant !
        </Button>
        {/*<button className="button btn btn-primary" onClick={this.openForm} style={{cursor: 'pointer'}}>Postuler maintenant !</button>*/}
      </Card>
    );
  }
}

const mapStateToProps = (state) => {
  return { user: state.session.user }
}

export default connect(mapStateToProps, { fetchMessages })(CardApply);
