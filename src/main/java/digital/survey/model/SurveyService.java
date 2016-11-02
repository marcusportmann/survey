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
import guru.mmp.application.util.ServiceUtil;
import guru.mmp.common.persistence.TransactionManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ejb.AsyncResult;
import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Default;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Future;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyService</code> class provides the Survey Service implementation.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("JpaQlInspection")
@ApplicationScoped
@Default
public class SurveyService
  implements ISurveyService
{
  /* Logger */
  @SuppressWarnings("unused")
  private static final Logger logger = LoggerFactory.getLogger(SurveyService.class);

  /* The name of the Survey Service instance. */
  private String instanceName = ServiceUtil.getServiceInstanceName("Survey Service");

  /**
   * The delay in milliseconds between attempts to retry sending a survey request.
   */
  private long SEND_SURVEY_REQUEST_RETRY_DELAY = 60L * 5L * 1000L;

  /* Entity Manager */
  @PersistenceContext(unitName = "Application")
  private EntityManager entityManager;

  /* Configuration Service */
  @Inject
  private IConfigurationService configurationService;

  /* The result of sending the survey requests. */
  private Future<Boolean> sendSurveyRequestsResult;

  /* Background Survey Request Sender */
  @Inject
  BackgroundSurveyRequestSender backgroundSurveyRequestSender;

  /**
   * Constructs a new <code>SurveyService</code>.
   */
  public SurveyService()
  {
    sendSurveyRequestsResult = new AsyncResult<>(false);
  }

  /**
   * Delete the survey audience.
   *
   * @param surveyAudience the survey audience to delete
   *
   * @return <code>true</code> if the survey audience was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyAudience(SurveyAudience surveyAudience)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyAudience))
      {
        entityManager.remove(surveyAudience);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyAudience(surveyAudience.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey audience with ID ("
          + surveyAudience.getId() + ")", e);
    }
  }

  /**
   * Delete the survey audience with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            audience
   *
   * @return <code>true</code> if the survey audience was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyAudience sa where sa.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey audience with ID (" + id + ")",
          e);
    }
  }

  /**
   * Delete the survey audience member.
   *
   * @param surveyAudienceMember the survey audience member to delete
   *
   * @return <code>true</code> if the survey audience member was deleted or <code>false</code>
   *         otherwise
   */
  @Transactional
  public boolean deleteSurveyAudienceMember(SurveyAudienceMember surveyAudienceMember)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyAudienceMember))
      {
        entityManager.remove(surveyAudienceMember);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyAudienceMember(surveyAudienceMember.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey audience member with ID ("
          + surveyAudienceMember.getId() + ")", e);
    }

  }

  /**
   * Delete the survey audience member with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            audience member
   *
   * @return <code>true</code> if the survey audience member was deleted or <code>false</code>
   *         otherwise
   */
  @Transactional
  public boolean deleteSurveyAudienceMember(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery(
          "delete from SurveyAudienceMember sam where sam.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey audience member with ID (" + id
          + ")", e);
    }
  }

  /**
   * Delete the survey definition.
   *
   * @param surveyDefinition the survey definition to delete
   *
   * @return <code>true</code> if the survey definition was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyDefinition(SurveyDefinition surveyDefinition)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyDefinition))
      {
        entityManager.remove(surveyDefinition);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyDefinition(surveyDefinition.getId(), surveyDefinition.getVersion());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey definition with ID ("
          + surveyDefinition.getId() + ") and version (" + surveyDefinition.getVersion() + ")", e);
    }
  }

  /**
   * Delete all versions of the survey definition with the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to, along with the version of the
   *           survey definition, uniquely identify the survey definitions
   *
   * @return <code>true</code> if all versions of the survey definition were deleted or
   *        <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyDefinition sd where sd.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to delete all versions of the survey definition with ID (" + id + ")", e);
    }
  }

  /**
   * Delete the survey definition with the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return <code>true</code> if the survey definition was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyDefinition(UUID id, int version)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery(
          "delete from SurveyDefinition sd where sd.id = :id AND sd.version = :version");

      query.setParameter("id", id);
      query.setParameter("version", version);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey definition with ID (" + id
          + ") and version (" + version + ")", e);
    }
  }

  /**
   * Delete the survey instance.
   *
   * @param surveyInstance the survey instance to delete
   *
   * @return <code>true</code> if the survey instance was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyInstance(SurveyInstance surveyInstance)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyInstance))
      {
        entityManager.remove(surveyInstance);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyInstance(surveyInstance.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey instance with ID ("
          + surveyInstance.getId() + ")", e);
    }
  }

  /**
   * Delete the survey instance with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            instance
   *
   * @return <code>true</code> if the survey instance was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyInstance si where si.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey instance with ID (" + id + ")",
          e);
    }
  }

  /**
   * Delete the survey request.
   *
   * @param surveyRequest the survey request to delete
   *
   * @return <code>true</code> if the survey request was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyRequest(SurveyRequest surveyRequest)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyRequest))
      {
        entityManager.remove(surveyRequest);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyRequest(surveyRequest.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey request with ID ("
          + surveyRequest.getId() + ")", e);
    }
  }

  /**
   * Delete the survey request with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            request
   *
   * @return <code>true</code> if the survey request was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyRequest(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyRequest sr where sr.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey request with ID (" + id + ")",
          e);
    }
  }

  /**
   * Delete the survey response.
   *
   * @param surveyResponse the survey response to delete
   *
   * @return <code>true</code> if the survey response was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyResponse(SurveyResponse surveyResponse)
    throws SurveyServiceException
  {
    try
    {
      if (entityManager.contains(surveyResponse))
      {
        entityManager.remove(surveyResponse);
        entityManager.flush();

        return true;
      }
      else
      {
        return deleteSurveyResponse(surveyResponse.getId());
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey response with ID ("
          + surveyResponse.getId() + ")", e);
    }
  }

  /**
   * Delete the survey response with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            response
   *
   * @return <code>true</code> if the survey response was deleted or <code>false</code> otherwise
   */
  @Transactional
  public boolean deleteSurveyResponse(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("delete from SurveyResponse sr where sr.id = :id");

      query.setParameter("id", id);

      return (query.executeUpdate() > 0);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to delete the survey response with ID (" + id + ")",
          e);
    }
  }

  /**
   * Delete the survey response for the survey request with the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey request
   *
   * @return <code>true</code> if the survey response was deleted successfully or <code>false</code>
   *         otherwise
   *
   * @throws SurveyServiceException
   */
  public boolean deleteSurveyResponseForSurveyRequest(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "DELETE FROM SurveyResponse sr WHERE sr.request.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return (query.executeUpdate() == 1);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to delete the survey response for the survey request (" + id + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey audience members for the survey audience.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *               audience
   * @param filter the filter used to limit the matching survey audience members
   *
   * @return the filtered survey audiences members for the survey audience
   */
  public List<SurveyAudienceMember> getFilteredMembersForSurveyAudience(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sam FROM SurveyAudienceMember sam"
          + " WHERE sam.audience.id = :id AND ((UPPER(sam.firstName) LIKE :filter)"
          + " OR (UPPER(sam.lastName) LIKE :filter) OR (UPPER(sam.email) LIKE :filter))";

      TypedQuery<SurveyAudienceMember> query = entityManager.createQuery(sql,
          SurveyAudienceMember.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audience members for the survey audience with ID (" + id
          + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey audiences for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey audiences
   *
   * @return the filtered survey audiences for the organisation
   */
  public List<SurveyAudience> getFilteredSurveyAudiencesForOrganisation(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sa FROM SurveyAudience sa WHERE sa.organisation.id = :id"
          + " AND (UPPER(sa.name) LIKE :filter)";

      TypedQuery<SurveyAudience> query = entityManager.createQuery(sql, SurveyAudience.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audiences for the organisation with ID (" + id
          + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Retrieve the summaries for the latest versions of the filtered survey definitions for the
   * organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the summaries for the latest versions of the filtered survey definitions for the
   *         organisation
   */
  @SuppressWarnings("unchecked")
  public List<SurveyDefinitionSummary> getFilteredSurveyDefinitionSummariesForOrganisation(UUID id,
      String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT SD.ID, SD.VERSION, SD.NAME FROM SURVEY.SURVEY_DEFINITIONS SD"
          + " JOIN (SELECT ID, MAX(VERSION) AS LATEST_VERSION FROM SURVEY.SURVEY_DEFINITIONS"
          + " GROUP BY ID) LATEST ON (SD.VERSION = LATEST.LATEST_VERSION AND SD.ID = LATEST.ID)"
          + " WHERE SD.ORGANISATION_ID = ?1 AND UPPER(SD.NAME) LIKE ?2";

      Query query = entityManager.createNativeQuery(sql, SurveyDefinitionSummary.class);

      query.setParameter(1, id);
      query.setParameter(2, "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the summaries for the filtered latest versions of the survey"
          + " definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the filtered survey instances for all versions of the survey definition
   */
  public List<SurveyInstance> getFilteredSurveyInstancesForSurveyDefinition(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT si FROM SurveyInstance si JOIN si.definition sd"
          + " WHERE sd.id = :id AND (UPPER(si.name) LIKE :filter)";

      TypedQuery<SurveyInstance> query = entityManager.createQuery(sql, SurveyInstance.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the filtered survey instances for the survey definition with ID ("
          + id + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey requests for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey requests are associated with
   * @param filter the filter used to limit the matching survey requests
   *
   * @return the filtered survey requests for the survey instance
   */
  public List<SurveyRequest> getFilteredSurveyRequestsForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyRequest sr JOIN sr.instance si WHERE si.id = :id"
          + " AND ((UPPER(sr.firstName) LIKE :filter) OR (UPPER(sr.lastName) LIKE :filter)"
          + " OR (UPPER(sr.email) LIKE :filter))";

      TypedQuery<SurveyRequest> query = entityManager.createQuery(sql, SurveyRequest.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the filtered survey requests for the survey instance with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the summaries for the filtered survey responses for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey responses are associated with
   * @param filter the filter used to limit the matching survey responses
   *
   * @return the summaries for the filtered survey responses for the survey instance
   */
  public List<SurveyResponseSummary> getFilteredSurveyResponseSummariesForSurveyInstance(UUID id,
      String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT srs FROM SurveyResponseSummary srs JOIN srs.instance si"
          + " JOIN srs.request req WHERE si.id = :id AND ((UPPER(req.firstName) LIKE :filter)"
          + " OR (UPPER(req.lastName) LIKE :filter) OR (UPPER(req.email) LIKE :filter))";

      TypedQuery<SurveyResponseSummary> query = entityManager.createQuery(sql,
          SurveyResponseSummary.class);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the summaries for the filtered survey"
          + " responses for the survey instance with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the latest version number for the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey definition
   *
   * @return the latest version number for the survey definition or 0 if the survey definition
   *         could not be found
   */
  public int getLatestVersionNumberForSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT MAX(sd.version) FROM SurveyDefinition sd WHERE sd.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the latest version number for the survey definition with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the latest version of the survey definition identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to, along with the version of the
   *           survey definition, uniquely identify the survey definition
   *
   * @return the latest version of the survey definition identified by the specified ID
   */
  public SurveyDefinition getLatestVersionOfSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sd FROM SurveyDefinition sd WHERE sd.id = :id AND"
          + " sd.version = (SELECT MAX(sd.version) FROM SurveyDefinition sd WHERE sd.id = :id)";

      TypedQuery<SurveyDefinition> query = entityManager.createQuery(sql, SurveyDefinition.class);

      query.setParameter("id", id);

      List<SurveyDefinition> surveyDefinitions = query.getResultList();

      if (surveyDefinitions.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyDefinitions.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the latest version of the survey definition (" + id + ")", e);
    }
  }

  /**
   * Returns the maximum number of times that sending of a survey request will be attempted.
   *
   * @return the maximum number of times that sending of a survey request will be attempted
   */
  public int getMaximumSurveyRequestSendAttempts()
    throws SurveyServiceException
  {
    try
    {
      return configurationService.getInteger(SurveyApplication
          .MAXIMUM_SURVEY_REQUEST_SEND_ATTEMPTS_CONFIGURATION_KEY);
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the maximum number of survey send attempts", e);
    }

  }

  /**
   * Retrieve the survey audience members for the survey audience.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the survey audiences members for the survey audience
   */
  public List<SurveyAudienceMember> getMembersForSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sam FROM SurveyAudienceMember sam WHERE sam.audience.id = :id";

      TypedQuery<SurveyAudienceMember> query = entityManager.createQuery(sql,
          SurveyAudienceMember.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audience members for the survey audience with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the next survey request that has been queued for sending.
   * <p/>
   * The survey request will be locked to prevent duplicate sending.
   *
   * @return the next survey request that has been queued for sending or <code>null</code> if no
   *         survey requests are currently queued for sending
   */
  @SuppressWarnings("unchecked")
  public SurveyRequest getNextSurveyRequestQueuedForSending()
    throws SurveyServiceException
  {
    // Retrieve the Transaction Manager
    TransactionManager transactionManager = TransactionManager.getTransactionManager();
    javax.transaction.Transaction existingTransaction = null;

    try
    {
      if (transactionManager.isTransactionActive())
      {
        existingTransaction = transactionManager.beginNew();
      }
      else
      {
        transactionManager.begin();
      }

      String selectSQL =
          "SELECT ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS, SEND_ATTEMPTS, LOCK_NAME, LAST_PROCESSED FROM SURVEY.SURVEY_REQUESTS WHERE STATUS=?1 AND (LAST_PROCESSED<?2 OR LAST_PROCESSED IS NULL) FETCH FIRST 1 ROWS ONLY FOR UPDATE";

      Query selectQuery = entityManager.createNativeQuery(selectSQL, SurveyRequest.class);

      Timestamp processedBefore = new Timestamp(System.currentTimeMillis()
          - SEND_SURVEY_REQUEST_RETRY_DELAY);

      selectQuery.setParameter(1, SurveyRequestStatus.QUEUED_FOR_SENDING.code());
      selectQuery.setParameter(2, processedBefore);

      List<SurveyRequest> surveyRequests = selectQuery.getResultList();

      SurveyRequest surveyRequest = null;

      if (surveyRequests.size() > 0)
      {
        surveyRequest = surveyRequests.get(0);

        surveyRequest.setStatus(SurveyRequestStatus.SENDING);
        surveyRequest.setLockName(instanceName);

        String lockSQL = "UPDATE SURVEY.SURVEY_REQUESTS SET STATUS=?1, LOCK_NAME=?2 WHERE ID=?3";

        Query lockQuery = entityManager.createNativeQuery(lockSQL);

        lockQuery.setParameter(1, SurveyRequestStatus.SENDING.code());
        lockQuery.setParameter(2, instanceName);
        lockQuery.setParameter(3, surveyRequest.getId());

        if (lockQuery.executeUpdate() != 1)
        {
          throw new SurveyServiceException(String.format(
              "No rows were affected as a result of executing the SQL statement (%s)", lockSQL));

        }
      }

      transactionManager.commit();

      return surveyRequest;
    }
    catch (Throwable e)
    {
      try
      {
        transactionManager.rollback();
      }
      catch (Throwable f)
      {
        logger.error("Failed to rollback the transaction while retrieving the next survey request"
            + " that has been queued for sending from the database", f);
      }

      throw new SurveyServiceException(
          "Failed to retrieve the next survey request that has been queued for sending", e);
    }
    finally
    {
      try
      {
        if (existingTransaction != null)
        {
          transactionManager.resume(existingTransaction);
        }
      }
      catch (Throwable e)
      {
        logger.error("Failed to resume the original transaction while retrieving the next survey"
            + " request that has been queued for sending from the database", e);
      }
    }
  }

  /**
   * Returns the number of filtered survey audience members for the survey audience.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *               audience
   * @param filter the filter used to limit the matching survey audience members
   *
   * @return the number of filtered survey audience members for the survey audience
   */
  public int getNumberOfFilteredMembersForSurveyAudience(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sam.id) FROM SurveyAudienceMember sam "
          + " WHERE sam.audience.id = :id AND ((UPPER(sam.firstName) LIKE :filter)"
          + " OR (UPPER(sam.lastName) LIKE :filter) OR (UPPER(sam.email) LIKE :filter))");

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey audience members for the survey audience with ID ("
          + id + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Returns the number of filtered survey audiences for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey audiences
   *
   * @return the number of filtered survey audiences for the organisation
   */
  public int getNumberOfFilteredSurveyAudiencesForOrganisation(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sa.id) FROM SurveyAudience sa"
          + " WHERE sa.organisation.id = :id AND (UPPER(sa.name) LIKE :filter)");

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey audiences for the organisation with ID (" + id
          + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Retrieve the number of filtered survey definitions for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the number of filtered survey definitions for the organisation
   */
  public int getNumberOfFilteredSurveyDefinitionsForOrganisation(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(DISTINCT SD.ID) FROM SURVEY.SURVEY_DEFINITIONS SD"
          + " WHERE SD.ORGANISATION_ID = ?1 AND UPPER(SD.NAME) LIKE ?2";

      Query query = entityManager.createNativeQuery(sql);

      query.setParameter(1, id);
      query.setParameter(2, "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the number of filtered latest versions"
          + " of the survey definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the number of filtered survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the number of filtered survey instances for all versions of the survey definition
   */
  public int getNumberOfFilteredSurveyInstancesForSurveyDefinition(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT si FROM SurveyInstance si JOIN si.definition sd"
          + " WHERE sd.id = :id AND (UPPER(si.name) LIKE :filter)";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of filtered survey instances for the survey definition with"
          + " ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the number of filtered survey requests for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey requests are associated with
   * @param filter the filter used to limit the matching survey requests
   *
   * @return the number of filtered survey requests for the survey instance
   */
  public int getNumberOfFilteredSurveyRequestsForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql =
          "SELECT COUNT(sr.id) FROM SurveyRequest sr JOIN sr.instance si WHERE si.id = :id"
          + " AND ((UPPER(sr.firstName) LIKE :filter) OR (UPPER(sr.lastName) LIKE :filter)"
          + " OR (UPPER(sr.email) LIKE :filter))";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of filtered survey requests for the survey instance with ID ("
          + id + ")", e);
    }
  }

  /**
   * Retrieve the number of filtered survey responses for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey responses are associated with
   * @param filter the filter used to limit the matching survey responses
   *
   * @return the number of filtered survey responses for the survey instance
   */
  public int getNumberOfFilteredSurveyResponsesForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(sr.id) FROM SurveyResponse sr JOIN sr.instance si"
          + " JOIN sr.request req WHERE si.id = :id AND ((UPPER(req.firstName) LIKE :filter)"
          + " OR (UPPER(req.lastName) LIKE :filter) OR (UPPER(req.email) LIKE :filter))";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);
      query.setParameter("filter", "%" + filter.toUpperCase() + "%");

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of filtered survey responses for the survey instance with ID ("
          + id + ")", e);
    }
  }

  /**
   * Returns the number of members for the survey audience.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the number of members for the survey audience
   */
  public int getNumberOfMembersForSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sam.id) FROM SurveyAudienceMember sam"
          + " WHERE sam.audience.id = :id");

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of members for the survey audience with ID (" + id + ")",
          e);
    }
  }

  /**
   * Returns the number of survey audiences for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the number of survey audiences for the organisation
   */
  public int getNumberOfSurveyAudiencesForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sa.id) FROM SurveyAudience sa"
          + " WHERE sa.organisation.id = :id");

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey audiences for the organisation with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the number of survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the number of survey definitions for the organisation
   */
  public int getNumberOfSurveyDefinitionsForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(DISTINCT SD.ID) FROM SURVEY.SURVEY_DEFINITIONS SD"
          + " WHERE SD.ORGANISATION_ID = ?1";

      Query query = entityManager.createNativeQuery(sql);

      query.setParameter(1, id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the number of latest versions of the"
          + " survey definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the number of survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   *
   * @return the number of survey instances for all versions of the survey definition
   */
  public int getNumberOfSurveyInstancesForSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(si.id) FROM SurveyInstance si JOIN si.definition sd"
          + " WHERE sd.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey instances for the survey definition with ID (" + id + ")",
          e);
    }
  }

  /**
   * Retrieve the number of survey requests for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey requests are associated with
   *
   * @return the number of survey requests for the survey instance
   */
  public int getNumberOfSurveyRequestsForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(sr.id) FROM SurveyRequest sr JOIN sr.instance si"
          + " WHERE si.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey requests for the survey instance with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the number of survey responses for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey responses are associated with
   *
   * @return the number of survey responses for the survey instance
   */
  public int getNumberOfSurveyResponsesForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(sr.id) FROM SurveyResponse sr JOIN sr.instance si"
          + " WHERE si.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey responses for the survey instance with ID ("
          + id + ")", e);
    }
  }

  /**
   * Retrieve the survey request to survey response mappings for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey requests and survey responses are associated with
   *
   * @return the the survey request to survey response mappings for the survey instance
   */
  @SuppressWarnings("unchecked")
  public List<SurveyRequestToSurveyResponseMapping> getRequestToResponseMappingsForSurveyInstance(
      UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT REQUEST.ID AS REQUEST_ID, REQUEST.REQUESTED AS REQUESTED,"
          + " RESPONSE.ID AS RESPONSE_ID, RESPONSE.RESPONDED AS RESPONDED"
          + " FROM SURVEY.SURVEY_REQUESTS REQUEST"
          + " JOIN SURVEY.SURVEY_RESPONSES RESPONSE ON REQUEST.ID = RESPONSE.SURVEY_REQUEST_ID"
          + " JOIN SURVEY.SURVEY_INSTANCES INSTANCE ON REQUEST.SURVEY_INSTANCE_ID = INSTANCE.ID"
          + " WHERE INSTANCE.ID = ?1";

      Query query = entityManager.createNativeQuery(sql, "SurveyRequestToSurveyResponseMapping");

      query.setParameter(1, id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey request to survey response"
          + " mappings for the survey instance with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey audience identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the survey audience identified by the specified ID or <code>null</code> if the survey
   *         audience could not be found
   */
  public SurveyAudience getSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sa FROM SurveyAudience sa WHERE sa.id = :id";

      TypedQuery<SurveyAudience> query = entityManager.createQuery(sql, SurveyAudience.class);

      query.setParameter("id", id);

      List<SurveyAudience> surveyAudiences = query.getResultList();

      if (surveyAudiences.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyAudiences.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey audience (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey audience member identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience member
   *
   * @return the survey audience member identified by the specified ID or <code>null</code> if the
   *         survey audience member could not be found
   */
  public SurveyAudienceMember getSurveyAudienceMember(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sam FROM SurveyAudienceMember sam WHERE sam.id = :id";

      TypedQuery<SurveyAudienceMember> query = entityManager.createQuery(sql,
          SurveyAudienceMember.class);

      query.setParameter("id", id);

      List<SurveyAudienceMember> surveyAudienceMembers = query.getResultList();

      if (surveyAudienceMembers.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyAudienceMembers.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey audience member (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the survey audiences for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the survey audiences for the organisation
   */
  public List<SurveyAudience> getSurveyAudiencesForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sa FROM SurveyAudience sa WHERE sa.organisation.id = :id";

      TypedQuery<SurveyAudience> query = entityManager.createQuery(sql, SurveyAudience.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audiences for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey definition identified by the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return the survey definition identified by the specified ID and version or <code>null</code>
   *         if the survey definition could not be found
   */
  public SurveyDefinition getSurveyDefinition(UUID id, int version)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sd FROM SurveyDefinition sd WHERE sd.id = :id AND sd.version = :version";

      TypedQuery<SurveyDefinition> query = entityManager.createQuery(sql, SurveyDefinition.class);

      query.setParameter("id", id);
      query.setParameter("version", version);

      List<SurveyDefinition> surveyDefinitions = query.getResultList();

      if (surveyDefinitions.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyDefinitions.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the version (" + version
          + ") of the survey definition (" + id + ")", e);
    }
  }

  /**
   * Retrieve the summaries for the latest versions of the survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the summaries for the latest versions of the survey definitions for the organisation
   */
  @SuppressWarnings("unchecked")
  public List<SurveyDefinitionSummary> getSurveyDefinitionSummariesForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT SD.ID, SD.VERSION, SD.NAME FROM SURVEY.SURVEY_DEFINITIONS SD"
          + " JOIN (SELECT ID, MAX(VERSION) AS LATEST_VERSION FROM SURVEY.SURVEY_DEFINITIONS"
          + " GROUP BY ID) LATEST ON (SD.VERSION = LATEST.LATEST_VERSION AND SD.ID = LATEST.ID)"
          + " WHERE SD.ORGANISATION_ID = ?1";

      Query query = entityManager.createNativeQuery(sql, SurveyDefinitionSummary.class);

      query.setParameter(1, id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the summaries for the latest versions of the survey definitions for"
          + " the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the summary for the survey definition identified by the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return the summary for the survey definition identified by the specified ID and version or
   *         <code>null</code> if the survey definition could not be found
   */
  public SurveyDefinitionSummary getSurveyDefinitionSummary(UUID id, int version)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sds FROM SurveyDefinitionSummary sds WHERE sds.id = :id"
          + " AND sds .version = :version";

      TypedQuery<SurveyDefinitionSummary> query = entityManager.createQuery(sql,
          SurveyDefinitionSummary.class);

      query.setParameter("id", id);
      query.setParameter("version", version);

      List<SurveyDefinitionSummary> surveyDefinitionSummaries = query.getResultList();

      if (surveyDefinitionSummaries.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyDefinitionSummaries.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the summary for the version (" + version
          + ") of the survey definition (" + id + ")", e);
    }

  }

  /**
   * Retrieve the survey instance identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey instance
   *
   * @return the survey instance identified by the specified ID or <code>null</code> if the survey
   *         instance could not be found
   */
  public SurveyInstance getSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT si FROM SurveyInstance si WHERE si.id = :id";

      TypedQuery<SurveyInstance> query = entityManager.createQuery(sql, SurveyInstance.class);

      query.setParameter("id", id);

      List<SurveyInstance> surveyInstances = query.getResultList();

      if (surveyInstances.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyInstances.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey instance (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   *
   * @return the survey instances for all versions of the survey definition
   */
  public List<SurveyInstance> getSurveyInstancesForSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT si FROM SurveyInstance si JOIN si.definition sd WHERE sd.id = :id";

      TypedQuery<SurveyInstance> query = entityManager.createQuery(sql, SurveyInstance.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey instances for the survey definition with ID (" + id + ")",
          e);
    }
  }

  /**
   * Retrieve the survey request identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey request
   *
   * @return the survey request identified by the specified ID or <code>null</code> if the survey
   *         request could not be found
   */
  public SurveyRequest getSurveyRequest(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyRequest sr WHERE sr.id = :id";

      TypedQuery<SurveyRequest> query = entityManager.createQuery(sql, SurveyRequest.class);

      query.setParameter("id", id);

      List<SurveyRequest> surveyRequests = query.getResultList();

      if (surveyRequests.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyRequests.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey request (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey request with the specified e-mail address for the survey instance with
   * the specified ID.
   *
   * @param id    the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *              instance that the survey request is associated with
   * @param email the e-mail address
   *
   * @return the survey request with the specified e-mail address for the survey instance with
   *         the specified ID or <code>null</code> if no matching service request could be found
   */
  public SurveyRequest getSurveyRequestForSurveyInstanceByEmail(UUID id, String email)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyRequest sr JOIN sr.instance si"
          + " WHERE si.id = :id AND sr.email = :email";

      TypedQuery<SurveyRequest> query = entityManager.createQuery(sql, SurveyRequest.class);

      query.setParameter("id", id);
      query.setParameter("email", email.toLowerCase());

      List<SurveyRequest> surveyRequests = query.getResultList();

      if (surveyRequests.size() > 0)
      {
        return surveyRequests.get(0);
      }
      else
      {
        return null;
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey request with the e-mail ("
          + email + ") for the survey instance (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey requests for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey requests are associated with
   *
   * @return the survey requests for the survey instance
   */
  public List<SurveyRequest> getSurveyRequestsForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyRequest sr JOIN sr.instance si WHERE si.id = :id";

      TypedQuery<SurveyRequest> query = entityManager.createQuery(sql, SurveyRequest.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey requests for the survey instance with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey response identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           response
   *
   * @return the survey response identified by the specified ID or <code>null</code> if the survey
   *         response could not be found
   */
  public SurveyResponse getSurveyResponse(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyResponse sr WHERE sr.id = :id";

      TypedQuery<SurveyResponse> query = entityManager.createQuery(sql, SurveyResponse.class);

      query.setParameter("id", id);

      List<SurveyResponse> surveyResponses = query.getResultList();

      if (surveyResponses.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyResponses.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey response (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey response associated with the survey request with the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           request the survey response is associated with
   *
   * @return the survey response associated with the survey request or <code>nul</code> if an
   *         associated survey response could not be found
   */
  public SurveyResponse getSurveyResponseForSurveyRequest(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyResponse sr WHERE sr.request.id = :id";

      TypedQuery<SurveyResponse> query = entityManager.createQuery(sql, SurveyResponse.class);

      query.setParameter("id", id);

      List<SurveyResponse> surveyResponses = query.getResultList();

      if (surveyResponses.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyResponses.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey response for the survey request (" + id + ")", e);
    }
  }

  /**
   * Retrieve the summaries for the survey responses for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey responses are associated with
   *
   * @return the summaries for the survey responses for the survey instance
   */
  public List<SurveyResponseSummary> getSurveyResponseSummariesForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql =
          "SELECT srs FROM SurveyResponseSummary srs JOIN srs.instance si WHERE si.id = :id";

      TypedQuery<SurveyResponseSummary> query = entityManager.createQuery(sql,
          SurveyResponseSummary.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the summaries for the survey responses"
          + " for the survey instance with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the summary for the survey response identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           response
   *
   * @return the summary for the survey response identified by the specified ID or <code>null</code>
   *         if the survey response could not be found
   */
  public SurveyResponseSummary getSurveyResponseSummary(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT srs FROM SurveyResponseSummary srs WHERE srs.id = :id";

      TypedQuery<SurveyResponseSummary> query = entityManager.createQuery(sql,
          SurveyResponseSummary.class);

      query.setParameter("id", id);

      List<SurveyResponseSummary> surveyResponseSummaries = query.getResultList();

      if (surveyResponseSummaries.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyResponseSummaries.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the summary for the survey response ("
          + id + ")", e);
    }
  }

  /**
   * Retrieve the the survey responses for the survey instance.
   *
   * NOTE: This is potentially a resource intensive operation if there are a large number of survey
   *       responses associated with a survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey responses are associated with
   *
   * @return the survey responses for the survey instance
   */
  public List<SurveyResponse> getSurveyResponsesForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyResponse sr JOIN sr.instance si WHERE si.id = :id";

      TypedQuery<SurveyResponse> query = entityManager.createQuery(sql, SurveyResponse.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey responses for the survey"
          + " instance with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey result for the survey instance with the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           instance
   *
   * @return the survey result for the survey instance with the specified ID
   *
   * @throws SurveyServiceException
   */
  public SurveyResult getSurveyResultForSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      SurveyInstance surveyInstance = getSurveyInstance(id);

      SurveyResult surveyResult = new SurveyResult(surveyInstance);

      // TODO: Check if we have too many survey responses to compile the survey result in real time.

      // TODO: Add caching of survey result in database.
      // This will require deleting the cached result if a new survey response is received.
      // It might be worth it to pregenerate the survey result once all the survey responses
      // have been received for the survey requests. This will only work on surveys that do
      // not allow anonymous responses where we can track the outstanding responses. Creating
      // a new survey request for this survey instance will ALSO invalidate the survey result

      // TODO: Make this more efficient by retrieving batches of survey responses rather than all
      // the survey responses at one time. Might require a list of IDs to be retrieved first
      // and then retrievals of 10 survey responses based on the next 10 IDs.
      List<SurveyResponse> surveyResponses = getSurveyResponsesForSurveyInstance(id);

      for (SurveyResponse surveyResponse : surveyResponses)
      {
        for (SurveyGroupRatingItemResponse groupRatingItemResponse :
            surveyResponse.getGroupRatingItemResponses())
        {
          SurveyGroupRatingItemResult groupRatingItemResult = surveyResult.getGroupRatingItemResult(
              groupRatingItemResponse.getGroupRatingItemDefinitionId(),
              groupRatingItemResponse.getGroupMemberDefinitionId());

          if (groupRatingItemResult != null)
          {
            groupRatingItemResult.addRating(groupRatingItemResponse.getRating());
          }
          else
          {
            throw new SurveyServiceException(
                "Failed to retrieve the survey result for the survey instance (" + id
                + "): Failed to find a survey group rating item result for the survey group rating item response ("
                + groupRatingItemResponse + ")");
          }
        }
      }

      return surveyResult;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey result for the survey instance (" + id + ")", e);
    }
  }

  /**
   * Increment the send attempts for the survey request.
   *
   * @param surveyRequest the survey request
   */
  @Transactional
  public void incrementSurveyRequestSendAttempts(SurveyRequest surveyRequest)
    throws SurveyServiceException
  {
    try
    {
      String sql = "UPDATE SURVEY.SURVEY_REQUESTS SET SEND_ATTEMPTS = SEND_ATTEMPTS + 1"
          + " WHERE ID = ?1";

      Query query = entityManager.createNativeQuery(sql);

      query.setParameter(1, surveyRequest.getId());

      if (query.executeUpdate() > 0)
      {
        surveyRequest.setSendAttempts(surveyRequest.getSendAttempts() + 1);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(String.format(
          "Failed to increment the send attempts for the survey request (%s)",
          surveyRequest.getId()), e);
    }
  }

  /**
   * Reset the survey request locks.
   *
   * @param status    the current status of the survey requests that have been locked
   * @param newStatus the new status for the survey requests that have been unlocked
   */
  @Transactional
  public void resetSurveyRequestLocks(SurveyRequestStatus status, SurveyRequestStatus newStatus)
    throws SurveyServiceException
  {
    try
    {
      String sql = "UPDATE SURVEY.SURVEY_REQUESTS SET STATUS =?1, LOCK_NAME=NULL"
          + " WHERE LOCK_NAME=?2 AND STATUS=?3";

      Query query = entityManager.createNativeQuery(sql);

      query.setParameter(1, status.code());
      query.setParameter(2, instanceName);
      query.setParameter(3, newStatus.code());

      query.executeUpdate();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(String.format("Failed to reset the locks for the survey"
          + " requests with status (%s) locked using the lock name (%s)", status, instanceName), e);
    }
  }

  /**
   * Save the survey audience.
   *
   * @param surveyAudience the survey audience
   *
   * @return the saved survey audience
   */
  @Transactional
  public SurveyAudience saveSurveyAudience(SurveyAudience surveyAudience)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyAudience))
      {
        surveyAudience = entityManager.merge(surveyAudience);

        entityManager.flush();

        entityManager.detach(surveyAudience);
      }

      return surveyAudience;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey audience with ID ("
          + surveyAudience.getId() + ")", e);
    }
  }

  /**
   * Save the survey audience member.
   *
   * @param surveyAudienceMember the survey audience member
   *
   * @return the saved survey response
   */
  @Transactional
  public SurveyAudienceMember saveSurveyAudienceMember(SurveyAudienceMember surveyAudienceMember)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyAudienceMember))
      {
        surveyAudienceMember = entityManager.merge(surveyAudienceMember);

        entityManager.flush();

        entityManager.detach(surveyAudienceMember);
      }

      return surveyAudienceMember;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey audience member with ID ("
          + surveyAudienceMember.getId() + ")", e);
    }
  }

  /**
   * Save the survey definition.
   *
   * @param surveyDefinition the survey definition
   *
   * @return the saved survey definition
   */
  @Transactional
  public SurveyDefinition saveSurveyDefinition(SurveyDefinition surveyDefinition)
    throws SurveyServiceException
  {
    try
    {
      // Check if a survey instance exists for the current version of the survey definition
      Query surveyInstanceExistsQuery = entityManager.createQuery(
          "SELECT COUNT(si.id) FROM SurveyInstance si JOIN si.definition sd"
          + " WHERE sd.id = :id AND sd.version = :version");

      surveyInstanceExistsQuery.setParameter("id", surveyDefinition.getId());
      surveyInstanceExistsQuery.setParameter("version", surveyDefinition.getVersion());

      boolean surveyInstanceExists =
          (((Number) surveyInstanceExistsQuery.getSingleResult()).intValue() > 0);

      // Duplicate the survey definition and increment the current version if required
      if (surveyInstanceExists)
      {
        entityManager.detach(surveyDefinition);

        surveyDefinition = surveyDefinition.duplicate();

        surveyDefinition.incrementVersion();
      }

      if (!entityManager.contains(surveyDefinition))
      {
        surveyDefinition = entityManager.merge(surveyDefinition);

        entityManager.flush();

        entityManager.detach(surveyDefinition);
      }

      return surveyDefinition;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey definition with ID ("
          + surveyDefinition.getId() + ")", e);
    }
  }

  /**
   * Save the survey instance.
   *
   * @param surveyInstance the survey instance
   *
   * @return the saved survey instance
   */
  @Transactional
  public SurveyInstance saveSurveyInstance(SurveyInstance surveyInstance)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyInstance))
      {
        surveyInstance = entityManager.merge(surveyInstance);

        entityManager.flush();

        entityManager.detach(surveyInstance);
      }

      return surveyInstance;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey instance with ID ("
          + surveyInstance.getId() + ")", e);
    }
  }

  /**
   * Save the survey request.
   *
   * @param surveyRequest the survey request
   *
   * @return the saved survey request
   */
  @Transactional
  public SurveyRequest saveSurveyRequest(SurveyRequest surveyRequest)
    throws SurveyServiceException
  {
    try
    {
      surveyRequest.setEmail(surveyRequest.getEmail().toLowerCase());

      if (!entityManager.contains(surveyRequest))
      {
        surveyRequest = entityManager.merge(surveyRequest);

        entityManager.flush();

        entityManager.detach(surveyRequest);
      }

      return surveyRequest;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey request with ID ("
          + surveyRequest.getId() + ")", e);
    }
  }

  /**
   * Save the survey response.
   *
   * @param surveyResponse the survey response
   *
   * @return the saved survey response
   */
  @Transactional
  public SurveyResponse saveSurveyResponse(SurveyResponse surveyResponse)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyResponse))
      {
        surveyResponse = entityManager.merge(surveyResponse);

        entityManager.flush();

        entityManager.detach(surveyResponse);
      }

      return surveyResponse;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey response with ID ("
          + surveyResponse.getId() + ")", e);
    }
  }

  /**
   * Send the survey request.
   *
   * @param surveyRequest the survey request to send
   *
   * @return <code>true</code> if the survey request was sent successfully or <code>false</code>
   *         otherwise
   */
  public boolean sendSurveyRequest(SurveyRequest surveyRequest)
    throws SurveyServiceException
  {
    try
    {
      MailHelper mailSenderHelper = new MailHelper(configurationService);

      mailSenderHelper.sendSurveyRequestMail(surveyRequest);

      return true;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to send the survey request ("
          + surveyRequest.getId() + ")", e);
    }
  }

  /**
   * Send a survey request, for the survey instance with the specified ID, to all survey audience
   * members for the survey audience.
   *
   * @param surveyInstanceId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                         survey instance that the survey requests should be sent for
   * @param audience         the survey audience
   */
  @Transactional
  public void sendSurveyRequestToAudience(UUID surveyInstanceId, SurveyAudience audience)
    throws SurveyServiceException
  {
    try
    {
      List<SurveyAudienceMember> members = getMembersForSurveyAudience(audience.getId());

      for (SurveyAudienceMember member : members)
      {
        SurveyRequest surveyRequest = getSurveyRequestForSurveyInstanceByEmail(surveyInstanceId,
            member.getEmail());

        if (surveyRequest == null)
        {
          SurveyInstance surveyInstance = getSurveyInstance(surveyInstanceId);

          surveyRequest = new SurveyRequest(surveyInstance, member.getFirstName(),
              member.getLastName(), member.getEmail());
        }
        else
        {
          deleteSurveyResponseForSurveyRequest(surveyRequest.getId());
        }

        surveyRequest.setRequested(new Date());
        surveyRequest.setStatus(SurveyRequestStatus.QUEUED_FOR_SENDING);

        saveSurveyRequest(surveyRequest);
      }

      sendSurveyRequests();
    }
    catch (SurveyServiceException e)
    {
      throw e;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to send the survey request(s) for the survey instance (" + surveyInstanceId
          + ") to the audience (" + audience.getId() + ")", e);
    }
  }

  /**
   * Send a survey request, for the survey instance with the specified ID, to the person with the
   * specified details.
   *
   * @param surveyInstanceId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                         survey instance that the survey request should be sent for
   * @param firstName        the first name(s) for the person that will be sent the survey request
   * @param lastName         the last name for the person that will be sent the survey request
   * @param email            the e-mail address for the person who will be sent the survey request
   */
  @Transactional
  public void sendSurveyRequestToPerson(UUID surveyInstanceId, String firstName, String lastName,
      String email)
    throws SurveyServiceException
  {
    try
    {
      SurveyRequest surveyRequest = getSurveyRequestForSurveyInstanceByEmail(surveyInstanceId,
          email);

      if (surveyRequest == null)
      {
        SurveyInstance surveyInstance = getSurveyInstance(surveyInstanceId);

        surveyRequest = new SurveyRequest(surveyInstance, firstName, lastName, email);
      }
      else
      {
        deleteSurveyResponseForSurveyRequest(surveyRequest.getId());
      }

      surveyRequest.setRequested(new Date());
      surveyRequest.setStatus(SurveyRequestStatus.QUEUED_FOR_SENDING);

      saveSurveyRequest(surveyRequest);

      sendSurveyRequests();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to send a survey request for the survey instance ("
          + surveyInstanceId + ") to the person (" + firstName + " " + lastName + " <" + email
          + ">)", e);

    }
  }

  /**
   * Send all the survey requests queued for sending asynchronously.
   */
  public synchronized void sendSurveyRequests()
  {
    if (sendSurveyRequestsResult.isDone())
    {
      /*
       * Asynchronously inform the Background Survey Request Sender that all pending survey requests
       * should be sent.
       */
      try
      {
        sendSurveyRequestsResult = backgroundSurveyRequestSender.send();
      }
      catch (Throwable e)
      {
        logger.error("Failed to invoke the Background Survey Request Sender to asynchronously send"
            + " all the survey requests queued for sending", e);
      }
    }
  }

  /**
   * Unlock the survey request.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey request
   * @param status the new status for the unlocked survey request
   */
  @Transactional
  public void unlockSurveyRequest(UUID id, SurveyRequestStatus status)
    throws SurveyServiceException
  {
    try
    {
      String sql = "UPDATE SURVEY.SURVEY_REQUESTS SET STATUS=?1, LOCK_NAME=NULL WHERE ID=?2";

      Query query = entityManager.createNativeQuery(sql);

      query.setParameter(1, status.code());
      query.setParameter(2, id);

      if (query.executeUpdate() != 1)
      {
        throw new SurveyServiceException(String.format(
            "No rows were affected as a result of executing the SQL statement (%s)", sql));
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(String.format(
          "Failed to unlock and set the status for the survey request (%s) to (%s)", id,
          status.description()), e);
    }
  }
}
