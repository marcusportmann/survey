/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.web.SurveyApplication;
import guru.mmp.application.configuration.IConfigurationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.mail.Message;
import javax.mail.Multipart;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import java.util.Properties;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>MailHelper</code> class.
 */
public class MailHelper
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(MailHelper.class);

  /**
   * The Configuration Service.
   */
  private IConfigurationService configurationService;

  /**
   * Constructs a new <code>MailHelper</code>.
   */
  public MailHelper(IConfigurationService configurationService)
    throws MailHelperException
  {
    this.configurationService = configurationService;
  }

  /**
   * Send the survey request mail.
   *
   * @param surveyRequest the survey request
   */
  public void sendSurveyRequestMail(SurveyResult surveyRequest)
    throws MailHelperException
  {
    try
    {
      // Retrieve the configuration values
      String host = configurationService.getString(SurveyApplication.MAIL_HOST_CONFIGURATION_KEY);
      String username = configurationService.getString(SurveyApplication
          .MAIL_USERNAME_CONFIGURATION_KEY);
      String password = configurationService.getString(SurveyApplication
          .MAIL_PASSWORD_CONFIGURATION_KEY);
      boolean isSecure = configurationService.getBoolean(SurveyApplication
          .MAIL_IS_SECURE_CONFIGURATION_KEY);
      String fromAddress = configurationService.getString(SurveyApplication
          .MAIL_FROM_ADDRESS_CONFIGURATION_KEY);
      String completeSurveyResponseUrl = configurationService.getString(SurveyApplication
          .COMPLETE_SURVEY_RESPONSE_URL_CONFIGURATION_KEY);

      // The subject
      String subject = "We want your opinion";

      // Initialise the mail properties
      Properties properties = new Properties();

      properties.put("mail.smtp.host", host);
      properties.put("mail.smtp.user", username);
      properties.put("mail.smtp.password", password);

      if (isSecure)
      {
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.auth", "true");
      }
      else
      {
        properties.put("mail.smtp.port", "25");
      }

      Session session = Session.getDefaultInstance(properties, null);

      MimeMessage message = new MimeMessage(session);

      message.setFrom(new InternetAddress(fromAddress));
      message.setReplyTo(new InternetAddress[] { new InternetAddress(fromAddress) });
      message.addRecipient(Message.RecipientType.TO, new InternetAddress(surveyRequest.getEmail()));
      message.setSubject(subject);

      Multipart multipart = new MimeMultipart();

      MimeBodyPart bodyPart = new MimeBodyPart();

      String content =
          "<div style=\"font-family: 'Open Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; font-size: 13px;\">"
          + "Dear " + surveyRequest.getFirstName() + ",<br/><br/>"
          + "Please click the button below to complete the <b>" + surveyRequest.getInstance()
          .getName() + "</b> survey.<br/><br/>" + "Thank you.<br/><br/>" + "Kind regards,<br/>"
          + "The Survey.Digital Team<br/><br/><br/>" + "<center>" + "<a href=\""
          + completeSurveyResponseUrl + "?surveyInstanceId=" + surveyRequest.getInstance().getId()
          + "&surveyRequestId=" + surveyRequest.getId()
          + "\" style=\"background: rgb(92, 144, 210) none; border-image-outset: 0px; border-image-repeat: stretch; border-image-slice: 100%; border-image-source: none; border-image-width: 1; border-radius: 2px; border: 1px solid rgb(54, 117, 197); box-sizing: border-box; color: rgb(255, 255, 255); cursor: pointer; display: inline-block; font-family: 'Open Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif; font-size: 13px; font-weight: 600; height: 31px; line-height: 19px; margin-bottom: 0px; padding: 5px 10px; text-align: center; text-decoration: none; vertical-align: middle; white-space: nowrap;\">Click here to complete the survey</a><br/><br/>" + "<span style=\"font-size: 10px;\">Please do not forward this e-mail as its survey link is unique to you.</span>" + "</center>" + "<div>";

      bodyPart.setContent(content, "text/html");

      multipart.addBodyPart(bodyPart);

//    for (MailAttachment mailAttachment : attachments)
//    {
//      MimeBodyPart attachment = new MimeBodyPart();
//
//      attachment.setFileName(mailAttachment.getName());
//      attachment.setContent(mailAttachment.getData(), mailAttachment.getContentType());
//      attachment.setDisposition(MimeBodyPart.ATTACHMENT);
//
//      multipart.addBodyPart(attachment);
//    }

      message.setContent(multipart);

      Transport transport = session.getTransport("smtp");

      transport.connect(host, username, password);

      logger.info("Successfully connected to the mail server (" + host + ") using the"
          + " username (" + username + ")");

      transport.sendMessage(message, message.getAllRecipients());
      transport.close();

      logger.info("Successfully sent the mail with subject (" + subject + ") to the recipient ("
          + surveyRequest.getEmail() + ") using the mail server (" + host + ")");

    }
    catch (Throwable e)
    {
      throw new MailHelperException("Failed to send the mail for the survey request ("
          + surveyRequest.getId() + ") for the person " + surveyRequest.getFirstName() + " "
          + surveyRequest.getLastName() + " <" + surveyRequest.getEmail() + ">", e);
    }
  }
}
