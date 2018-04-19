import React, { Component } from 'react';
import { connect } from 'react-redux';
import { createSession } from '../actions';
import { Link } from 'react-router-dom';
import { Field, reduxForm } from 'redux-form';

export const LINKEDIN_REDIRECT_URI = process.env.REACT_APP_LINKEDIN_REDIRECT_URI;
export const LINKEDIN_CLIENT_ID = process.env.REACT_APP_LINKEDIN_CLIENT_ID;

class SessionsNew extends Component {
  componentDidMount() {
    const { history } = this.props;

    // Just basic check if token exist in localstorage
    // dashboard will check if token is valid
    if (localStorage.getItem('token')) {
      this.props.history.push('/dashboard');
    }
  }

  onSubmit(values) {
    // this.props.createSession(values, this.props.history);
  }

  renderField(field) {
    const { meta: { touched, error }, type } = field;
    const className = `form-group ${touched && error ? 'has-danger' : ''}`

    return (
      <div className={className}>
        <label>{field.label}</label>
        <input
        className='form-control'
          type={type}
          {...field.input}
        />
        {touched ? error : ''}
      </div>
    );
  }

  render() {
    const { handleSubmit } = this.props;
    const linkedinOauth = `https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=${LINKEDIN_CLIENT_ID}&redirect_uri=${LINKEDIN_REDIRECT_URI}&state=kef`
    return (
      <div className='row align-items-center'>
        <div className='col-lg-6 text-center'>
          <div className="card d-md-block d-lg-block mb-4">
            <img className="card-img-top" src="/login_banner.png" alt="Card image cap"/>
            <div className="card-body">
              <h2>Move ideas forward 🍄</h2>
              <p>Finally the perfect place to work & live with people like you.</p>
              <a className='btn btn-primary btn-lg btn-block' href={linkedinOauth}>
                Let me <span className="icon icon-linkedin"> </span>
              </a>
              <p><small>LinkedIn is the best way for us to know you.</small></p>
            </div>
          </div>
        </div>

{/*        <p className='text-center'>ou</p>
        <form  onSubmit={handleSubmit(this.onSubmit.bind(this))}>
          <Field
            label="Email"
            name="email"
            type="text"
            component={this.renderField}
          />
          <Field
            label="Password"
            name="password"
            type="password"
            component={this.renderField}
          />
          <button type="submit" className="btn btn-primary">Submit</button>
          <Link className="btn btn-danger" to="/">
            Cancel
          </Link>
        </form>
*/}
      </div>
    );
  }
}

function validate(values) {
  // console.log(values) -> { title: 'asdf', categories: 'asd', content: 'isanda'}
  const errors = {};

  // Validate the inputs from 'values'
  if (!values.title || values.title.length < 3) {
    errors.title = "Title must be at least 3 characters";
  }

  // if errors is empty, the form is fine to submit
  // if errors has any properties. redux form assumes form is invalid
  return errors;
}

function mapStateToProps(state) {
  return { errorMessage: state.error };
}

export default reduxForm({
  validate,
  form: 'SessionsNewForm'
})(
  connect(mapStateToProps, { createSession })(SessionsNew)
);